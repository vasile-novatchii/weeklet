import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Thrown when the native print hand-off fails.
class PdfPrintException implements Exception {
  const PdfPrintException(this.message);

  final String message;

  @override
  String toString() => 'PdfPrintException: $message';
}

/// Opens the Android print dialog for a PDF file, using the file base name
/// as the print job name so "Save as PDF" proposes the custom file name.
class PdfPrintService {
  PdfPrintService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.infvyr.weeklet/pdf_print');

  final MethodChannel _channel;

  /// File base name without directory and without the `.pdf` extension.
  ///
  /// Android appends `.pdf` when saving, so the bare name avoids
  /// `name.pdf.pdf`.
  static String jobNameFor(String filePath) {
    final segments = filePath.split(RegExp(r'[/\\]'));
    final name = segments.isEmpty ? filePath : segments.last;
    if (name.toLowerCase().endsWith('.pdf')) {
      return name.substring(0, name.length - 4);
    }
    return name;
  }

  Future<void> printPdf({required String filePath}) async {
    try {
      await _channel.invokeMethod<void>('printPdf', <String, String>{
        'filePath': filePath,
        'jobName': jobNameFor(filePath),
      });
    } on PlatformException catch (e) {
      debugPrint('[PdfPrintService.printPdf] error: $e');
      throw PdfPrintException(e.message ?? e.code);
    } on MissingPluginException catch (e) {
      debugPrint('[PdfPrintService.printPdf] error: $e');
      throw PdfPrintException(e.message ?? 'Print channel unavailable');
    }
  }
}
