import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/domain/entities/expense.dart';

/// Utility class for grouping and organizing expenses
class ExpenseGrouping {
  ExpenseGrouping._();

  /// Groups expenses by ISO week number within the year
  ///
  /// Returns a map where key is (year, weekNumber) and value is list of expenses.
  /// Results are sorted by year and week (most recent first).
  static Map<({int year, int week}), List<Expense>> groupByWeek(
    List<Expense> expenses, {
    DateTime? now,
  }) {
    final grouped = <({int year, int week}), List<Expense>>{};

    for (final expense in expenses) {
      final date = expense.createdAt;
      final weekNumber = _getISOWeekNumber(date);
      final key = (year: date.year, week: weekNumber);

      grouped.putIfAbsent(key, () => []).add(expense);
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

  /// Groups expenses by day (date only, ignoring time)
  ///
  /// Returns a map where key is the date (day) and value is list of expenses.
  /// Results are sorted by date (earliest first within the group).
  static Map<DateTime, List<Expense>> groupByDay(
    List<Expense> expenses,
  ) {
    final grouped = <DateTime, List<Expense>>{};

    for (final expense in expenses) {
      final dateOnly = expense.createdAt.toDateOnly();
      grouped.putIfAbsent(dateOnly, () => []).add(expense);
    }

    // Sort by date (earliest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  /// Calculates the total amount of expenses
  static double calculateTotal(List<Expense> expenses) => expenses.fold(
    0.0,
    (sum, expense) => sum + expense.amount,
  );

  /// Calculates the ISO week number of the year
  ///
  /// Week 1 is the week containing January 4th.
  /// Uses ISO 8601 standard where weeks start on Monday.
  static int _getISOWeekNumber(DateTime date) {
    // Find the first day of the year
    final firstDayOfYear = DateTime(date.year, 1, 1);

    // Find the first Thursday of the year
    // (ISO week starts Monday, but week 1 is defined as the week containing
    // January 4th, which is always in week 1)
    final firstThursday = firstDayOfYear.add(
      Duration(days: (DateTime.thursday - firstDayOfYear.weekday + 7) % 7),
    );

    // Calculate the week number
    final daysSinceFirstThursday = date.difference(firstThursday).inDays;

    // Week 1 starts on the Monday before the first Thursday
    final weekNumber =
        ((daysSinceFirstThursday + firstThursday.weekday - 1) / 7).floor() + 1;

    return weekNumber;
  }
}
