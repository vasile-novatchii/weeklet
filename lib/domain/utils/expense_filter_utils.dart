import 'package:intl/intl.dart' show DateFormat;
import 'package:weeklet/domain/entities/expense.dart';

/// Utility class for extracting and managing expense filter options.
///
/// Provides functions to extract available years and months from a list
/// of expenses, sorted for optimal user experience.
class ExpenseFilterUtils {
  ExpenseFilterUtils._();

  /// Extracts unique years from expenses, sorted descending (newest first).
  ///
  /// Returns at least [currentYear] if the list is empty, ensuring there's
  /// always a default year available for filtering.
  static List<int> extractAvailableYears(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return [DateTime.now().year];
    }

    final years = expenses.map((e) => e.createdAt.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a)); // Descending: newest first

    return years;
  }

  /// Extracts unique months for a given year, sorted ascending (1-12).
  ///
  /// Returns months in January-December order for the specified [year].
  /// Returns an empty list if no expenses exist for that year.
  static List<int> extractAvailableMonthsForYear(
    List<Expense> expenses,
    int year,
  ) {
    final monthsInYear =
        expenses
            .where((e) => e.createdAt.year == year)
            .map((e) => e.createdAt.month)
            .toSet()
            .toList()
          ..sort(); // Ascending: 1-12 (Jan-Dec)

    return monthsInYear;
  }

  /// Gets the capitalised standalone full month name for [month] (1-12).
  ///
  /// [localeCode] is the in-app language code (e.g. 'en', 'ro', 'ru').
  /// Throws [RangeError] if month is not between 1-12.
  static String getMonthName(int month, String localeCode) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    final name = DateFormat('LLLL', localeCode).format(DateTime(2000, month));
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }

  /// Gets the standalone abbreviated month name for [month] (1-12).
  ///
  /// [localeCode] is the in-app language code (e.g. 'en', 'ro', 'ru').
  /// Throws [RangeError] if month is not between 1-12.
  static String getMonthAbbreviation(int month, String localeCode) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    return DateFormat('LLL', localeCode).format(DateTime(2000, month));
  }
}
