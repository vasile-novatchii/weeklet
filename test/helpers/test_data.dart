import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';

/// Returns a fake [Expense] with sensible defaults.
/// Override [id], [amount], or [categoryId] as needed per test.
Expense fakeExpense({
  String id = 'exp-1',
  double amount = 100.0,
  String categoryId = 'cat-1',
}) => Expense(
  id: id,
  amount: amount,
  description: 'Test expense',
  categoryId: categoryId,
  createdAt: DateTime(DateTime.now().year, 5, 1),
);

/// Returns a fake [Category] with sensible defaults.
/// Override [id] or [name] as needed per test.
Category fakeCategory({
  String id = 'cat-1',
  String name = 'Food',
}) => Category(
  id: id,
  name: name,
  icon: 'fastfood',
  createdAt: DateTime(2025, 1, 1),
);

/// Returns a fake [Income] with sensible defaults.
/// Override [id] or [amount] as needed per test.
Income fakeIncome({
  String id = 'inc-1',
  double amount = 500.0,
}) => Income(
  id: id,
  amount: amount,
  description: 'Salary',
  date: DateTime(DateTime.now().year, 5, 1),
  createdAt: DateTime(DateTime.now().year, 5, 1),
);

/// Returns an [ExpenseSuccess] state seeded with [expenses].
/// Defaults to a single [fakeExpense()] when [expenses] is null.
ExpenseSuccess fakeExpenseSuccess({List<Expense>? expenses}) {
  final list = expenses ?? [fakeExpense()];
  return ExpenseSuccess(
    allExpenses: list,
    filteredExpenses: list,
    selectedYear: DateTime.now().year,
    availableYears: [DateTime.now().year],
    availableMonths: const [5],
  );
}

/// Returns an [IncomeSuccess] state seeded with [incomes].
/// Defaults to a single [fakeIncome()] when [incomes] is null.
IncomeSuccess fakeIncomeSuccess({List<Income>? incomes}) {
  final list = incomes ?? [fakeIncome()];
  return IncomeSuccess(
    allIncomes: list,
    filteredIncomes: list,
    selectedYear: DateTime.now().year,
    availableYears: [DateTime.now().year],
    availableMonths: const [5],
  );
}

/// Returns a [MonthlyStatsLoaded] state with a simple non-empty stats seed.
MonthlyStatsLoaded fakeMonthlyStatsLoaded() => MonthlyStatsLoaded(
  stats: const MonthlyStats(
    totalIncome: 1000.0,
    totalExpenses: 500.0,
    balance: 500.0,
    incomeGrowthPercentage: 0.0,
    expenseGrowthPercentage: 0.0,
    categoryStats: [],
  ),
  year: DateTime.now().year,
);
