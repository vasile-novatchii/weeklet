import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weeklet/core/di/service_locator.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/platform/pdf_print_service.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/utils/pdf_share_helper.dart';

enum _ExportAction { share, print }

/// Presents the post-export actions for a generated PDF.
///
/// iOS (and any non-Android platform) opens the share sheet directly. On
/// Android a small sheet offers Share and Print / Save as PDF, so the user
/// can save the file under its custom name via the native print dialog.
class PdfExportActions {
  const PdfExportActions._();

  static Future<void> present(
    BuildContext context, {
    required String filePath,
    required String subject,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      await PdfShareHelper.share(filePath: filePath, subject: subject);
      return;
    }

    final action = await showModalBottomSheet<_ExportAction>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(l10n.exportActionShare),
                onTap: () => Navigator.of(sheetContext).pop(
                  _ExportAction.share,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: Text(l10n.exportActionPrint),
                onTap: () => Navigator.of(sheetContext).pop(
                  _ExportAction.print,
                ),
              ),
            ],
          ),
        );
      },
    );

    switch (action) {
      case _ExportAction.share:
        await PdfShareHelper.share(filePath: filePath, subject: subject);
      case _ExportAction.print:
        try {
          await sl<PdfPrintService>().printPdf(filePath: filePath);
        } on PdfPrintException catch (e) {
          debugPrint('[PdfExportActions.present] print error: $e');
          if (context.mounted) {
            context.showErrorSnackBar(
              AppLocalizations.of(context).exportPrintFailed,
            );
          }
        }
      case null:
        break;
    }
  }
}
