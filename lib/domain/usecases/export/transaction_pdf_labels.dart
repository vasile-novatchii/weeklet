import 'package:equatable/equatable.dart';

/// Localized strings for the expenses and income PDFs.
///
/// The widget resolves these from `AppLocalizations` so the domain layer stays
/// Flutter-free.
class TransactionPdfLabels extends Equatable {
  const TransactionPdfLabels({
    required this.reportTitleExpenses,
    required this.reportTitleIncome,
    required this.generatedLabel,
    required this.recordsLabel,
    required this.totalLabel,
    required this.columnDate,
    required this.columnCategory,
    required this.columnDescription,
    required this.columnAmount,
    required this.noRecordsLabel,
    required this.unknownCategoryLabel,
  });

  final String reportTitleExpenses;
  final String reportTitleIncome;
  final String generatedLabel;
  final String recordsLabel;
  final String totalLabel;
  final String columnDate;
  final String columnCategory;
  final String columnDescription;
  final String columnAmount;
  final String noRecordsLabel;
  final String unknownCategoryLabel;

  @override
  List<Object> get props => [
    reportTitleExpenses,
    reportTitleIncome,
    generatedLabel,
    recordsLabel,
    totalLabel,
    columnDate,
    columnCategory,
    columnDescription,
    columnAmount,
    noRecordsLabel,
    unknownCategoryLabel,
  ];
}
