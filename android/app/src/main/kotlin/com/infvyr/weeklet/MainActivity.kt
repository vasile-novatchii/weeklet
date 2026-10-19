package com.infvyr.weeklet

import android.content.Context
import android.print.PrintAttributes
import android.print.PrintManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PDF_PRINT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "printPdf") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            try {
                val filePath = call.argument<String>("filePath")
                val jobName = call.argument<String>("jobName")
                if (filePath.isNullOrBlank() || jobName.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "filePath and jobName are required", null)
                    return@setMethodCallHandler
                }

                val file = File(filePath).canonicalFile
                val cacheRoot = cacheDir.canonicalPath + File.separator
                if (!file.path.startsWith(cacheRoot) ||
                    !file.name.endsWith(".pdf", ignoreCase = true)
                ) {
                    result.error("INVALID_PATH", "Only cached PDF files can be printed", null)
                    return@setMethodCallHandler
                }
                if (!file.isFile) {
                    result.error("FILE_NOT_FOUND", "PDF file does not exist", null)
                    return@setMethodCallHandler
                }

                val printManager = getSystemService(Context.PRINT_SERVICE) as PrintManager
                printManager.print(
                    jobName,
                    PdfPrintAdapter(file, jobName),
                    PrintAttributes.Builder().build(),
                )
                result.success(null)
            } catch (e: Exception) {
                result.error("PRINT_FAILED", e.message, null)
            }
        }
    }

    private companion object {
        const val PDF_PRINT_CHANNEL = "com.infvyr.weeklet/pdf_print"
    }
}
