import 'package:weeklet/domain/entities/statistics.dart';

/// Utility class for evolution statistics calculations and data filtering
class EvolutionStatsUtils {
  EvolutionStatsUtils._();

  /// Gets snapshots that have actual data (income or expenses > 0)
  static List<MonthlySnapshot> getSnapshotsWithData(
    EvolutionStats evolutionStats,
  ) =>
      evolutionStats.snapshots
          .where((s) => s.totalIncome > 0 || s.totalExpenses > 0)
          .toList();

  /// Gets the maximum total income from snapshots with data
  static double getMaxIncomeFromSnapshots(List<MonthlySnapshot> snapshots) {
    if (snapshots.isEmpty) return 0;
    return snapshots
        .map((s) => s.totalIncome)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Gets the maximum total income across all snapshots
  static double getMaxIncome(EvolutionStats evolutionStats) {
    if (evolutionStats.snapshots.isEmpty) return 0;
    return evolutionStats.snapshots
        .map((s) => s.totalIncome)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Gets the maximum total expenses across all snapshots
  static double getMaxExpenses(EvolutionStats evolutionStats) {
    if (evolutionStats.snapshots.isEmpty) return 0;
    return evolutionStats.snapshots
        .map((s) => s.totalExpenses)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Gets the maximum of income or expenses across all snapshots.
  /// Used for chart scaling in bar charts so neither series overflows the axis.
  static double getMaxTotal(EvolutionStats evolutionStats) {
    if (evolutionStats.snapshots.isEmpty) return 0;
    double max = 0;
    for (final snapshot in evolutionStats.snapshots) {
      final monthMax = snapshot.totalIncome > snapshot.totalExpenses
          ? snapshot.totalIncome
          : snapshot.totalExpenses;
      if (monthMax > max) max = monthMax;
    }
    // Add 10% padding for better visualization
    return max * 1.1;
  }

  /// Gets all unique category names across snapshots, sorted alphabetically
  static List<String> getAllCategoryNames(List<MonthlySnapshot> snapshots) {
    final allCategories = <String>{};
    for (final snapshot in snapshots) {
      for (final catStat in snapshot.categoryStats) {
        allCategories.add(catStat.category.name);
      }
    }
    return allCategories.toList()..sort();
  }

  /// Gets an appropriate Y-axis interval based on the maximum value
  /// Used for grid spacing in bar charts
  static double getYInterval(double maxY) {
    if (maxY <= 2000) return 500;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    return 5000;
  }
}
