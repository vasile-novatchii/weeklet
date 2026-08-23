import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/domain/entities/income.dart';

/// Utility class for grouping and organizing incomes
class IncomeGrouping {
  IncomeGrouping._();

  /// Groups incomes by ISO week number within the year
  ///
  /// Returns a map where key is (year, weekNumber) and value is list of incomes.
  /// Results are sorted by year and week (most recent first).
  static Map<({int year, int week}), List<Income>> groupByWeek(
    List<Income> incomes, {
    DateTime? now,
  }) {
    final grouped = <({int year, int week}), List<Income>>{};

    for (final income in incomes) {
      final date = income.date;
      final weekNumber = _getISOWeekNumber(date);
      final key = (year: date.year, week: weekNumber);

      grouped.putIfAbsent(key, () => []).add(income);
    }

    // Sort by year and week (most recent first)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.week.compareTo(a.week);
      });

    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  /// Groups incomes by day (date only, ignoring time)
  ///
  /// Returns a map where key is the date (day) and value is list of incomes.
  /// Results are sorted by date (earliest first within the group).
  static Map<DateTime, List<Income>> groupByDay(
    List<Income> incomes,
  ) {
    final grouped = <DateTime, List<Income>>{};

    for (final income in incomes) {
      final dateOnly = income.date.toDateOnly();
      grouped.putIfAbsent(dateOnly, () => []).add(income);
    }

    // Sort by date (earliest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  /// Calculates the total amount of incomes
  static double calculateTotal(List<Income> incomes) => incomes.fold(
    0.0,
    (sum, income) => sum + income.amount,
  );

  /// Calculates the ISO week number of the year
  static int _getISOWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final firstThursday = firstDayOfYear.add(
      Duration(days: (DateTime.thursday - firstDayOfYear.weekday + 7) % 7),
    );
    final daysSinceFirstThursday = date.difference(firstThursday).inDays;
    final weekNumber =
        ((daysSinceFirstThursday + firstThursday.weekday - 1) / 7).floor() + 1;
    return weekNumber;
  }
}
