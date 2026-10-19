import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/utils/expense_filter_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';

/// Filter bar for filtering expenses by month and year.
///
/// Displays two dropdowns (year and month) that show only available options
/// extracted from the loaded expenses. Allows filtering by:
/// - Year only (all months for that year)
/// - Month only (the month in the selected year)
/// - Both year and month (specific month/year combination)
class ExpenseFilterBar extends StatelessWidget {
  const ExpenseFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<ExpenseBloc>().state;

    if (state is! ExpenseSuccess) {
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
              items: [null, ...state.availableMonths], // null = "All Months"
              selectedItem: state.selectedMonth,
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
                context.read<ExpenseBloc>().add(
                  FilterDateChanged(month: month),
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
                  context.read<ExpenseBloc>().add(
                    FilterDateChanged(year: year),
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
