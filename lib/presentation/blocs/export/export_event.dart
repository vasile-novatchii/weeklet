import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/usecases/export/stats_pdf_labels.dart';

sealed class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when user taps export on the Expenses screen.
final class ExportExpensesStarted extends ExportEvent {
  const ExportExpensesStarted({
    required this.expenses,
    required this.categories,
    required this.currencySymbol,
    required this.year,
    required this.month,
  });

  final List<Expense> expenses;
  final List<Category> categories;
  final String currencySymbol;
  final int year;
  final int month;

  @override
  List<Object?> get props => [
    expenses,
    categories,
    currencySymbol,
    year,
    month,
  ];
}

/// Dispatched when user taps export on the Income screen.
final class ExportIncomeStarted extends ExportEvent {
  const ExportIncomeStarted({
    required this.incomes,
    required this.currencySymbol,
    required this.year,
    required this.month,
  });

  final List<Income> incomes;
  final String currencySymbol;
  final int year;
  final int month;

  @override
  List<Object?> get props => [incomes, currencySymbol, year, month];
}

/// Dispatched when user taps export on the Stats screen.
final class ExportStatsStarted extends ExportEvent {
  const ExportStatsStarted({
    required this.stats,
    required this.monthRows,
    required this.year,
    required this.month,
    required this.currencySymbol,
    required this.localeCode,
    required this.labels,
    required this.categoryColors,
  });

  final MonthlyStats stats;
  final List<MonthlySnapshot> monthRows;
  final int year;

  /// Null means all months.
  final int? month;
  final String currencySymbol;
  final String localeCode;
  final StatsPdfLabels labels;
  final Map<String, int> categoryColors;

  @override
  List<Object?> get props => [
    stats,
    monthRows,
    year,
    month,
    currencySymbol,
    localeCode,
    labels,
    categoryColors,
  ];
}

/// Dispatched by widget after handling ExportSuccess or ExportFailure.
final class ResetExportRequested extends ExportEvent {
  const ResetExportRequested();
}
