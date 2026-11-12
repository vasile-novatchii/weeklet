import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_tab.dart';

class StatsTabsSection extends StatelessWidget {
  const StatsTabsSection({
    super.key,
    required this.currentTab,
  });

  final StatsTab currentTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color:
            context.colorScheme.surfaceContainerHighest.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: StatsTabButton(
              title: l10n.statsTabMonthly,
              isSelected: currentTab == StatsTab.monthly,
              onTap: () {
                context.read<StatsBloc>().add(
                  const ChangeStatsTab(StatsTab.monthly),
                );
              },
            ),
          ),
          Expanded(
            child: StatsTabButton(
              title: l10n.statsTabAnnualEvolution,
              isSelected: currentTab == StatsTab.annual,
              onTap: () {
                context.read<StatsBloc>().add(
                  const ChangeStatsTab(StatsTab.annual),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StatsTabButton extends StatelessWidget {
  const StatsTabButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? context.theme.appBarTheme.backgroundColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: context.theme.appBarTheme.backgroundColor!.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : context.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}
