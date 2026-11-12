import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

/// Builds and sends the share/print hand-off for an exported PDF.
///
/// Builds the share_plus hand-off with the file name and PDF mime type. The
/// Android Print / Save as PDF file name is handled separately by
/// PdfPrintService via PdfExportActions.
class PdfShareHelper {
  const PdfShareHelper._();

  static const String mimeType = 'application/pdf';

  /// Builds [ShareParams] carrying the file name and PDF mime type.
  static ShareParams buildParams({
    required String filePath,
    required String subject,
  }) {
    final fileName = Uri.file(filePath).pathSegments.last;
    return ShareParams(
      files: [XFile(filePath, mimeType: mimeType, name: fileName)],
      fileNameOverrides: [fileName],
      subject: subject,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
    );
  }

  /// Opens the system share sheet for the exported PDF.
  static Future<ShareResult> share({
    required String filePath,
    required String subject,
  }) => SharePlus.instance.share(
    buildParams(filePath: filePath, subject: subject),
  );
}
