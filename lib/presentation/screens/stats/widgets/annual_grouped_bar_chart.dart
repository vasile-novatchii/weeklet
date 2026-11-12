import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/utils/evolution_stats_utils.dart';
import 'package:weeklet/domain/utils/expense_filter_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class AnnualGroupedBarChart extends StatelessWidget {
  const AnnualGroupedBarChart({
    super.key,
    required this.evolutionStats,
    required this.currencySymbol,
  });

  final EvolutionStats evolutionStats;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshotsWithData = EvolutionStatsUtils.getSnapshotsWithData(
      evolutionStats,
    );

    if (snapshotsWithData.isEmpty) {
      return const SizedBox.shrink(); // Empty state handled in parent
    }

    final maxY = EvolutionStatsUtils.getMaxTotal(evolutionStats);
    final interval = EvolutionStatsUtils.getYInterval(maxY);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          bottom: 20,
          left: 16,
          right: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                l10n.statsIncomeVsExpensesTitle,
                style: context.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY == 0 ? 100 : maxY, // Safely handle 0
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          context.colorScheme.onSurface.withValues(alpha: 0.9),
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final isIncome = rodIndex == 0;
                        return BarTooltipItem(
                          '${isIncome ? l10n.incomeBarLabel : l10n.expensesBarLabel}\n',
                          TextStyle(
                            color: context.colorScheme.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: NumberFormatter.formatCompactWithSign(
                                rod.toY,
                                currencySymbol,
                                isIncome: isIncome,
                              ),
                              style: TextStyle(
                                color: isIncome
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final style = context.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          );
                          if (value.toInt() < 0 ||
                              value.toInt() >= snapshotsWithData.length) {
                            return const SizedBox.shrink();
                          }
                          final snapshot = snapshotsWithData[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              ExpenseFilterUtils.getMonthAbbreviation(
                                snapshot.month,
                                context.locale.languageCode,
                              ),
                              style: style,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: interval == 0 ? 100 : interval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              NumberFormatter.formatCompact(value, '').trim(),
                              style: context.labelSmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    checkToShowHorizontalLine: (value) =>
                        value > 0 && (interval > 0 && value % interval == 0),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: context.colorScheme.outline.withValues(alpha: .3),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    snapshotsWithData.length,
                    (index) {
                      final snapshot = snapshotsWithData[index];
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: snapshot.totalIncome,
                            color: context.successColor,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: snapshot.totalExpenses,
                            color: context.colorScheme.error,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  context,
                  l10n.incomeBarLabel,
                  context.successColor,
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  context,
                  l10n.expensesBarLabel,
                  context.colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String title, Color color) =>
      Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
