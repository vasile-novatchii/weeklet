import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';

/// Business rules for when period filter bars are shown.
///
/// A filter bar is hidden only when no data exists in any period, so the user
/// is never trapped in an empty period.
class FilterVisibilityUtils {
  FilterVisibilityUtils._();

  /// Show the expense filter when any expense exists in any period.
  static bool showExpenseFilter(List<Expense> allExpenses) =>
      allExpenses.isNotEmpty;

  /// Show the income filter when any income exists in any period.
  static bool showIncomeFilter(List<Income> allIncomes) =>
      allIncomes.isNotEmpty;

  /// Show the stats filter when any year has at least one month with data.
  static bool showStatsFilter(Map<int, List<int>> availablePeriods) =>
      availablePeriods.values.any((months) => months.isNotEmpty);
}
