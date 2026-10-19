import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/utils/expense_filter_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';

class StatsFilterBar extends StatelessWidget {
  const StatsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<StatsBloc>().state;

    if (state is! MonthlyStatsLoaded) {
      return const SizedBox.shrink();
    }

    // Use available periods from state, fall back to current year/month if empty
    final years = state.availableYears.isEmpty
        ? [state.year]
        : state.availableYears;
    final months = state.availablePeriods[state.year] ?? [];

    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        spacing: 12,
        children: [
          // Month Dropdown (nullable, includes "All Months" option)
          Expanded(
            flex: 2,
            child: CommonDropdownButton<int?>(
              items: [null, ...months],
              selectedItem: state.month,
              itemBuilder: (month) => Text(
                month == null
                    ? l10n.allMonthsLabel
                    : ExpenseFilterUtils.getMonthName(
                        month,
                        context.locale.languageCode,
                      ),
              ),
              hint: l10n.selectMonthHint,
              onChanged: (month) {
                context.read<StatsBloc>().add(
                  LoadMonthlyStats(
                    month: month,
                    year: state.year,
                  ),
                );
              },
            ),
          ),

          // Year Dropdown
          Expanded(
            child: CommonDropdownButton<int>(
              items: years,
              selectedItem: state.year,
              itemBuilder: (year) => Text(year.toString()),
              hint: l10n.selectYearHint,
              onChanged: (year) {
                if (year != null) {
                  context.read<StatsBloc>().add(
                    LoadMonthlyStats(
                      month: state.month,
                      year: year,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
