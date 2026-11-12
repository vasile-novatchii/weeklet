import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/utils/evolution_stats_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/stats/widgets/monthly_item/monthly_item.dart';

class MonthlyExpensesList extends StatelessWidget {
  const MonthlyExpensesList({
    super.key,
    required this.evolutionStats,
    required this.currencySymbol,
  });

  final EvolutionStats evolutionStats;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Get snapshots with actual data
    final snapshotsWithData = EvolutionStatsUtils.getSnapshotsWithData(
      evolutionStats,
    );

    // Find the overall max (income or expenses) for scaling both bars equally
    final maxValue = snapshotsWithData.isEmpty
        ? 0.0
        : snapshotsWithData
              .expand((s) => [s.totalIncome, s.totalExpenses])
              .reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statsMonthlyBreakdownTitle,
              style: context.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...snapshotsWithData.map(
              (snapshot) => MonthlyItem(
                snapshot: snapshot,
                maxIncome: maxValue,
                currencySymbol: currencySymbol,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
