import 'package:equatable/equatable.dart';
import 'package:weeklet/domain/entities/category.dart';

class MonthlyStats extends Equatable {
  const MonthlyStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.incomeGrowthPercentage,
    required this.expenseGrowthPercentage,
    required this.categoryStats,
  });

  final double totalIncome;
  final double totalExpenses;
  final double balance;
  /// Growth percentage as a fraction, e.g. 0.12 means 12% growth.
  /// Negative values indicate a decrease. Compared to last month.
  final double incomeGrowthPercentage;

  /// Growth percentage as a fraction, e.g. -0.05 means 5% decrease.
  /// Negative values indicate an increase in expenses. Compared to last month.
  final double expenseGrowthPercentage;
  final List<CategoryStats> categoryStats;

  @override
  List<Object> get props => [
    totalIncome,
    totalExpenses,
    balance,
    incomeGrowthPercentage,
    expenseGrowthPercentage,
    categoryStats,
  ];
}

class CategoryStats extends Equatable {
  const CategoryStats({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });

  final Category category;
  final double totalAmount;
  final double
  percentage; // 0.0 to 1.0 (or 0-100 based on preference, I'll use 0.0-1.0)

  @override
  List<Object> get props => [category, totalAmount, percentage];
}

class MonthlySnapshot extends Equatable {
  const MonthlySnapshot({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.categoryStats,
  });

  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final List<CategoryStats> categoryStats;

  @override
  List<Object> get props => [
    month,
    year,
    totalIncome,
    totalExpenses,
    balance,
    categoryStats,
  ];
}

class EvolutionStats extends Equatable {
  const EvolutionStats({
    required this.snapshots,
  });

  final List<MonthlySnapshot> snapshots; // 12 items, Jan → Dec

  @override
  List<Object> get props => [snapshots];
}
