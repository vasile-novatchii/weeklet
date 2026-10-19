import 'dart:math';

import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/statistics.dart';

/// Business rules for the statistics PDF export.
class StatsExportUtils {
  StatsExportUtils._();

  static const List<String> _englishMonthSlugs = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];

  /// Export is offered only when the selection has income or expenses.
  static bool hasExportableData(MonthlyStats stats) =>
      stats.totalIncome > 0 || stats.totalExpenses > 0;

  /// Month rows for the all-months export, sorted ascending by month.
  ///
  /// Past year: Jan-Dec. Current year: Jan through the greater of the current
  /// month and the last month with data. Future year: Jan through the last
  /// month with data. Rows therefore always sum to the annual totals.
  ///
  /// [now] is a test seam; defaults to [DateTime.now] when omitted.
  static List<MonthlySnapshot> monthsForExport(
    EvolutionStats evolution,
    int year, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    var lastWithData = 0;
    for (final s in evolution.snapshots) {
      if ((s.totalIncome > 0 || s.totalExpenses > 0) &&
          s.month > lastWithData) {
        lastWithData = s.month;
      }
    }
    final cutoff = year < today.year
        ? 12
        : year == today.year
        ? max(today.month, lastWithData)
        : lastWithData;
    return evolution.snapshots.where((s) => s.month <= cutoff).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  /// File name, never localized and never built from user text.
  static String fileName(int year, int? month) => month == null
      ? 'weeklet_stats_$year.pdf'
      : 'weeklet_stats_${_englishMonthSlugs[month - 1]}_$year.pdf';

  /// Full 2-decimal amount with a leading '-' for negative balances.
  static String formatBalance(double balance, String currencySymbol) =>
      balance < 0
      ? '-${NumberFormatter.formatCurrency(balance.abs(), currencySymbol)}'
      : NumberFormatter.formatCurrency(balance, currencySymbol);

  /// Signed growth percentage from a fraction, e.g. 0.12 -> '+12.0%'.
  static String formatGrowth(double fraction) =>
      '${fraction >= 0 ? '+' : '-'}'
      '${(fraction * 100).abs().toStringAsFixed(1)}%';

  /// Share percentage from a fraction, e.g. 0.4532 -> '45.3%'.
  static String formatShare(double fraction) =>
      '${(fraction * 100).toStringAsFixed(1)}%';
}
