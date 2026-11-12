import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/category_color_utils.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

class ModernDonutChart extends StatelessWidget {
  const ModernDonutChart({
    super.key,
    required this.categoryStats,
    required this.totalExpenses,
    required this.currencySymbol,
  });

  final List<CategoryStats> categoryStats;
  final double totalExpenses;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) => BlocBuilder<StatsBloc, StatsState>(
    builder: (context, state) {
      final touchedIndex = state is MonthlyStatsLoaded
          ? state.touchedIndex
          : -1;

      return Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).statsSpendingByCategoryTitle,
                style: context.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 70,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  context.read<StatsBloc>().add(
                                    const ChartTouchInteraction(-1),
                                  );
                                  return;
                                }
                                context.read<StatsBloc>().add(
                                  ChartTouchInteraction(
                                    pieTouchResponse
                                        .touchedSection!
                                        .touchedSectionIndex,
                                  ),
                                );
                              },
                        ),
                        sections: _generateSections(context, touchedIndex),
                      ),
                    ),
                    // Center Text
                    SizedBox(
                      // == centerSpaceRadius * 2 (line 58) - donut hole's
                      // diameter.
                      width: 140,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context).statsDonutTotalLabel,
                            style: context.labelMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          EllipsisTooltipText(
                            text: NumberFormatter.formatCurrency(
                              totalExpenses,
                              currencySymbol,
                            ),
                            style: context.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Modern Legend
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(categoryStats.length, (index) {
                  final stat = categoryStats[index];
                  final isTouched = index == touchedIndex;
                  final isAnythingTouched = touchedIndex != -1;
                  final opacity = (isTouched || !isAnythingTouched) ? 1.0 : 0.4;
                  final color = CategoryColorUtils.getColor(
                    stat.category.name,
                  );

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: opacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isTouched ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            stat.category.name,
                            style: context.labelMedium?.copyWith(
                              color: context.colorScheme.onSurface,
                              fontWeight: isTouched
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    },
  );

  List<PieChartSectionData> _generateSections(
    BuildContext context,
    int touchedIndex,
  ) {
    if (categoryStats.isEmpty) {
      // Fallback slice if somehow empty is passed
      return [
        PieChartSectionData(
          color: context.colorScheme.surfaceContainerHighest,
          value: 1,
          radius: 20,
          showTitle: false,
        ),
      ];
    }

    return List.generate(categoryStats.length, (i) {
      final stat = categoryStats[i];
      final isTouched = i == touchedIndex;
      final double radius = isTouched ? 28.0 : 20.0;
      final color = CategoryColorUtils.getColor(stat.category.name);
      // Display-only floor (UI-SPEC section 1 / D-05): fl_chart draws slice
      // angles strictly proportional to `value`, so a sub-1% category would
      // be swallowed by `sectionsSpace`. Never applied to a numeric surface.
      final displayValue = max(stat.totalAmount, totalExpenses * 0.03);
      final percent = stat.percentage * 100;

      return PieChartSectionData(
        color: color,
        value: displayValue,
        title: '',
        radius: radius,
        showTitle: false,
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  percent < 1 ? '<1%' : '${percent.toInt()}%',
                  style: context.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.2,
      );
    });
  }
}
