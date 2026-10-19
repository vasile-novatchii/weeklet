import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/utils/expense_filter_utils.dart';
import 'package:weeklet/domain/utils/income_grouping.dart';

/// Utility class for extracting and managing income filter options.
class IncomeFilterUtils {
  IncomeFilterUtils._();

  /// Extracts unique years from incomes, sorted descending (newest first).
  static List<int> extractAvailableYears(List<Income> incomes) {
    if (incomes.isEmpty) {
      return [DateTime.now().year];
    }

    final years = incomes.map((e) => e.date.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    return years;
  }

  /// Extracts unique months for a given year, sorted ascending (1-12).
  static List<int> extractAvailableMonthsForYear(
    List<Income> incomes,
    int year,
  ) {
    final monthsInYear =
        incomes
            .where((e) => e.date.year == year)
            .map((e) => e.date.month)
            .toSet()
            .toList()
          ..sort();

    return monthsInYear;
  }

  /// Sums incomes for [year]; when [month] is null the whole year is summed.
  static double totalForPeriod(List<Income> incomes, int year, int? month) {
    final filtered = incomes.where(
      (e) => e.date.year == year && (month == null || e.date.month == month),
    );
    return IncomeGrouping.calculateTotal(filtered.toList());
  }

  /// Gets the month name for a given month number (1-12) in [localeCode].
  static String getMonthName(int month, String localeCode) =>
      ExpenseFilterUtils.getMonthName(month, localeCode);

  /// Gets the abbreviated month name for a month (1-12) in [localeCode].
  static String getMonthAbbreviation(int month, String localeCode) =>
      ExpenseFilterUtils.getMonthAbbreviation(month, localeCode);
}
