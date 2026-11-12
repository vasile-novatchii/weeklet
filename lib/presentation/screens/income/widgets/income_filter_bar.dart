import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/utils/income_filter_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';

class IncomeFilterBar extends StatelessWidget {
  const IncomeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<IncomeBloc>().state;

    if (state is! IncomeSuccess) {
      return const SizedBox.shrink();
    }

    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        spacing: 12,
        children: [
          // Month Dropdown
          Expanded(
            flex: 2,
            child: CommonDropdownButton<int?>(
              items: [null, ...state.availableMonths],
              selectedItem: state.selectedMonth,
              itemBuilder: (month) => Text(
                month == null
                    ? l10n.allMonthsLabel
                    : IncomeFilterUtils.getMonthName(
                        month,
                        context.locale.languageCode,
                      ),
              ),
              hint: l10n.selectMonthHint,
              onChanged: (month) {
                context.read<IncomeBloc>().add(
                  IncomeFilterDateChanged(month: month),
                );
              },
            ),
          ),

          // Year Dropdown
          Expanded(
            child: CommonDropdownButton<int>(
              items: state.availableYears,
              selectedItem: state.selectedYear,
              itemBuilder: (year) => Text(year.toString()),
              hint: l10n.selectYearHint,
              onChanged: (year) {
                if (year != null) {
                  context.read<IncomeBloc>().add(
                    IncomeFilterDateChanged(year: year),
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
