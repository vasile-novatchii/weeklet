package com.infvyr.weeklet

import android.os.Bundle
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintDocumentInfo
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** Streams an existing PDF file to the print spooler under a custom job name. */
class PdfPrintAdapter(
    private val file: File,
    private val jobName: String,
) : PrintDocumentAdapter() {

    private val executor: ExecutorService = Executors.newSingleThreadExecutor()

    override fun onLayout(
        oldAttributes: PrintAttributes?,
        newAttributes: PrintAttributes?,
        cancellationSignal: CancellationSignal,
        callback: LayoutResultCallback,
        extras: Bundle?,
    ) {
        if (cancellationSignal.isCanceled) {
            callback.onLayoutCancelled()
            return
        }
        val info = PrintDocumentInfo.Builder(jobName)
            .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
            .setPageCount(PrintDocumentInfo.PAGE_COUNT_UNKNOWN)
            .build()
        callback.onLayoutFinished(info, true)
    }

    override fun onWrite(
        pages: Array<out PageRange>?,
        destination: ParcelFileDescriptor,
        cancellationSignal: CancellationSignal,
        callback: WriteResultCallback,
    ) {
        // onWrite is delivered on the main thread; copy on a worker so a slow
        // spooler pipe cannot block the UI.
        try {
            executor.execute { copyToDestination(destination, cancellationSignal, callback) }
        } catch (e: Exception) {
            closeQuietly(destination)
            callback.onWriteFailed(e.message)
        }
    }

    override fun onFinish() {
        executor.shutdown()
    }

    private fun copyToDestination(
        destination: ParcelFileDescriptor,
        cancellationSignal: CancellationSignal,
        callback: WriteResultCallback,
    ) {
        // Owns and closes the destination descriptor when the stream closes.
        val output = ParcelFileDescriptor.AutoCloseOutputStream(destination)
        try {
            FileInputStream(file).use { input ->
                val buffer = ByteArray(16 * 1024)
                while (true) {
                    if (cancellationSignal.isCanceled) {
                        callback.onWriteCancelled()
                        return
                    }
                    val read = input.read(buffer)
                    if (read < 0) break
                    output.write(buffer, 0, read)
                }
                output.flush()
            }
            callback.onWriteFinished(arrayOf(PageRange.ALL_PAGES))
        } catch (e: Exception) {
            callback.onWriteFailed(e.message)
        } finally {
            try {
                output.close()
            } catch (_: IOException) {
            }
        }
    }

    private fun closeQuietly(descriptor: ParcelFileDescriptor) {
        try {
            descriptor.close()
        } catch (_: IOException) {
        }
    }
}
