import 'package:equatable/equatable.dart';

/// Localized strings for the stats PDF.
///
/// The widget resolves these from `AppLocalizations` so the domain layer stays
/// Flutter-free.
class StatsPdfLabels extends Equatable {
  const StatsPdfLabels({
    required this.reportTitle,
    required this.generatedLabel,
    required this.incomeLabel,
    required this.expensesLabel,
    required this.balanceLabel,
    required this.vsLastMonthLabel,
    required this.categoryBreakdownTitle,
    required this.columnCategory,
    required this.columnAmount,
    required this.columnShare,
    required this.monthBreakdownTitle,
    required this.columnMonth,
    required this.columnIncome,
    required this.columnExpenses,
    required this.columnBalance,
    required this.totalLabel,
    required this.noExpensesLabel,
  });

  final String reportTitle;
  final String generatedLabel;
  final String incomeLabel;
  final String expensesLabel;
  final String balanceLabel;
  final String vsLastMonthLabel;
  final String categoryBreakdownTitle;
  final String columnCategory;
  final String columnAmount;
  final String columnShare;
  final String monthBreakdownTitle;
  final String columnMonth;
  final String columnIncome;
  final String columnExpenses;
  final String columnBalance;
  final String totalLabel;
  final String noExpensesLabel;

  @override
  List<Object> get props => [
    reportTitle,
    generatedLabel,
    incomeLabel,
    expensesLabel,
    balanceLabel,
    vsLastMonthLabel,
    categoryBreakdownTitle,
    columnCategory,
    columnAmount,
    columnShare,
    monthBreakdownTitle,
    columnMonth,
    columnIncome,
    columnExpenses,
    columnBalance,
    totalLabel,
    noExpensesLabel,
  ];
}
