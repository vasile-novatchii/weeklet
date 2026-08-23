import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/utils/week_utils.dart';

/// Utility class for grouping and organizing expenses
class ExpenseGrouping {
  ExpenseGrouping._();

  /// Groups expenses by ISO 8601 week
  ///
  /// Returns a map where key is the ISO (year, week) pair and value is the list
  /// of expenses in that week.
  ///
  /// Ordering: the current week comes first, then all other weeks newest-first.
  /// The pin is a no-op when the current week has no expenses.
  ///
  /// The key year is the ISO year, not the calendar year, so entries dated
  /// Dec 29-31 can appear under the following ISO year's week 1.
  ///
  /// [now] exists only so the current-week pin is deterministically testable;
  /// it defaults to [DateTime.now].
  static Map<({int year, int week}), List<Expense>> groupByWeek(
    List<Expense> expenses, {
    DateTime? now,
  }) {
    final grouped = <({int year, int week}), List<Expense>>{};

    for (final expense in expenses) {
      final key = WeekUtils.isoWeekOf(expense.createdAt);

      grouped.putIfAbsent(key, () => []).add(expense);
    }

    // Sort by year and week (most recent first)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final yearCompare = b.year.compareTo(a.year);
        if (yearCompare != 0) return yearCompare;
        return b.week.compareTo(a.week);
      });

    // Pin the current week to the top when it has entries (D-12)
    final currentKey = WeekUtils.isoWeekOf(now ?? DateTime.now());
    if (sortedKeys.remove(currentKey)) {
      sortedKeys.insert(0, currentKey);
    }

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
}
