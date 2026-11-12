import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/repositories/statistics_repository.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({
    required this.expenseRepository,
    required this.incomeRepository,
    required this.categoryRepository,
  });

  final ExpenseRepository expenseRepository;
  final IncomeRepository incomeRepository;
  final CategoryRepository categoryRepository;

  @override
  Future<MonthlyStats> getMonthlyStats(int? month, int year) async {
    // If month is null, calculate annual stats for the entire year
    if (month == null) {
      return _getAnnualStats(year);
    }

    // 1. Get current month data
    final currentExpenses = await expenseRepository.getExpensesByMonthYear(
      month,
      year,
    );
    final allIncomes = await incomeRepository.getIncomes();
    final currentIncomes = allIncomes
        .where((i) => i.date.month == month && i.date.year == year)
        .toList();

    // 2. Get previous month data (for growth calculation)
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final prevExpenses = await expenseRepository.getExpensesByMonthYear(
      prevMonth,
      prevYear,
    );
    final prevIncomes = allIncomes
        .where((i) => i.date.month == prevMonth && i.date.year == prevYear)
        .toList();

    // 3. Calculate totals
    final totalIncome = currentIncomes.fold(0.0, (sum, i) => sum + i.amount);
    final totalExpense = currentExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final balance = totalIncome - totalExpense;

    final prevTotalIncome = prevIncomes.fold(0.0, (sum, i) => sum + i.amount);
    final prevTotalExpense = prevExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // 4. Calculate growth
    final incomeGrowth = _calculateGrowth(totalIncome, prevTotalIncome);
    final expenseGrowth = _calculateGrowth(totalExpense, prevTotalExpense);

    // 5. Category breakdown
    final allCategories = await categoryRepository.getAllCategories();
    final categoryStats = <CategoryStats>[];

    for (final category in allCategories) {
      final categoryExpenses = currentExpenses.where(
        (e) => e.categoryId == category.id,
      );
      final categoryTotal = categoryExpenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );

      if (categoryTotal > 0) {
        categoryStats.add(
          CategoryStats(
            category: category,
            totalAmount: categoryTotal,
            percentage: totalExpense > 0 ? categoryTotal / totalExpense : 0.0,
          ),
        );
      }
    }

    // Sort by amount descending
    categoryStats.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return MonthlyStats(
      totalIncome: totalIncome,
      totalExpenses: totalExpense,
      balance: balance,
      incomeGrowthPercentage: incomeGrowth,
      expenseGrowthPercentage: expenseGrowth,
      categoryStats: categoryStats,
    );
  }

  Future<MonthlyStats> _getAnnualStats(int year) async {
    // Get all expenses and incomes for the entire year
    final allExpenses = await expenseRepository.getAllExpenses();
    final allIncomes = await incomeRepository.getIncomes();

    final yearExpenses =
        allExpenses.where((e) => e.createdAt.year == year).toList();
    final yearIncomes =
        allIncomes.where((i) => i.date.year == year).toList();

    // Calculate totals for the entire year
    final totalIncome =
        yearIncomes.fold(0.0, (sum, i) => sum + i.amount);
    final totalExpense =
        yearExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final balance = totalIncome - totalExpense;

    // Compare with previous year for growth
    final prevYear = year - 1;
    final prevYearExpenses =
        allExpenses.where((e) => e.createdAt.year == prevYear).toList();
    final prevYearIncomes =
        allIncomes.where((i) => i.date.year == prevYear).toList();

    final prevTotalIncome =
        prevYearIncomes.fold(0.0, (sum, i) => sum + i.amount);
    final prevTotalExpense =
        prevYearExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final incomeGrowth = _calculateGrowth(totalIncome, prevTotalIncome);
    final expenseGrowth = _calculateGrowth(totalExpense, prevTotalExpense);

    // Category breakdown for the year
    final allCategories = await categoryRepository.getAllCategories();
    final categoryStats = <CategoryStats>[];

    for (final category in allCategories) {
      final categoryExpenses = yearExpenses
          .where((e) => e.categoryId == category.id);
      final categoryTotal = categoryExpenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );

      if (categoryTotal > 0) {
        categoryStats.add(
          CategoryStats(
            category: category,
            totalAmount: categoryTotal,
            percentage: totalExpense > 0 ? categoryTotal / totalExpense : 0.0,
          ),
        );
      }
    }

    categoryStats.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return MonthlyStats(
      totalIncome: totalIncome,
      totalExpenses: totalExpense,
      balance: balance,
      incomeGrowthPercentage: incomeGrowth,
      expenseGrowthPercentage: expenseGrowth,
      categoryStats: categoryStats,
    );
  }

  @override
  Future<EvolutionStats> getEvolutionStats(int year) async {
    final snapshots = <MonthlySnapshot>[];

    // Hoist outside loop — D-12
    final allIncomes = await incomeRepository.getIncomes();
    final allCategories = await categoryRepository.getAllCategories();

    // Fixed Jan–Dec iteration — D-01
    for (int m = 1; m <= 12; m++) {
      final monthExpenses =
          await expenseRepository.getExpensesByMonthYear(m, year);
      final monthIncomes = allIncomes
          .where((inc) => inc.date.month == m && inc.date.year == year)
          .toList();

      final totalIncome =
          monthIncomes.fold(0.0, (sum, inc) => sum + inc.amount);
      final totalExpenses =
          monthExpenses.fold(0.0, (sum, exp) => sum + exp.amount);
      final balance = totalIncome - totalExpenses;

      final categoryStats = <CategoryStats>[];
      for (final category in allCategories) {
        final categoryTotal = monthExpenses
            .where((e) => e.categoryId == category.id)
            .fold(0.0, (sum, e) => sum + e.amount);
        if (categoryTotal > 0) {
          categoryStats.add(
            CategoryStats(
              category: category,
              totalAmount: categoryTotal,
              percentage:
                  totalExpenses > 0 ? categoryTotal / totalExpenses : 0.0,
            ),
          );
        }
      }
      categoryStats.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      snapshots.add(
        MonthlySnapshot(
          month: m,
          year: year,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          balance: balance,
          categoryStats: categoryStats,
        ),
      );
    }

    return EvolutionStats(snapshots: snapshots);
  }

  @override
  Future<Map<int, List<int>>> getAvailablePeriods() async {
    final expenses = await expenseRepository.getAllExpenses();
    final incomes = await incomeRepository.getIncomes();

    final periods = <int, Set<int>>{};

    // Extract periods from expenses
    for (final expense in expenses) {
      periods.putIfAbsent(expense.createdAt.year, () => {}).add(expense.createdAt.month);
    }

    // Extract periods from incomes
    for (final income in incomes) {
      periods.putIfAbsent(income.date.year, () => {}).add(income.date.month);
    }

    // Convert sets to sorted lists
    final result = <int, List<int>>{};
    for (final entry in periods.entries) {
      result[entry.key] = entry.value.toList()..sort();
    }

    return result;
  }

  double _calculateGrowth(double current, double previous) {
    if (previous == 0) return 0.0; // Or 1.0 (100%)? 0.0 means no comparison.
    return (current - previous) / previous;
  }
}
