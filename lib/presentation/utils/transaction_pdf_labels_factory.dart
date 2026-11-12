import 'package:weeklet/domain/usecases/export/transaction_pdf_labels.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// Resolves localized expenses/income PDF labels from [AppLocalizations].
class TransactionPdfLabelsFactory {
  const TransactionPdfLabelsFactory._();

  static TransactionPdfLabels fromL10n(AppLocalizations l10n) =>
      TransactionPdfLabels(
        reportTitleExpenses: l10n.pdfReportTitleExpenses,
        reportTitleIncome: l10n.pdfReportTitleIncome,
        generatedLabel: l10n.statsPdfGeneratedLabel,
        recordsLabel: l10n.pdfRecordsLabel,
        totalLabel: l10n.statsPdfTotal,
        columnDate: l10n.pdfColumnDate,
        columnCategory: l10n.statsPdfColumnCategory,
        columnDescription: l10n.pdfColumnDescription,
        columnAmount: l10n.statsPdfColumnAmount,
        noRecordsLabel: l10n.pdfNoRecords,
        unknownCategoryLabel: l10n.pdfUnknownCategory,
      );
}
