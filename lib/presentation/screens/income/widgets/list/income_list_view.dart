import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/utils/income_grouping.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/income/widgets/list/income_week_group_view.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';

class IncomeListView extends StatelessWidget {
  const IncomeListView({
    super.key,
    required this.incomes,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final List<Income> incomes;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return EmptyStateView(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.incomeEmptyTitle,
        subtitle: l10n.incomeEmptySubtitle,
      );
    }

    final groupedByWeek = IncomeGrouping.groupByWeek(incomes);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 50),
      itemCount: groupedByWeek.length,
      itemBuilder: (context, index) {
        final entry = groupedByWeek.entries.elementAt(index);
        return IncomeWeekGroupView(
          weekNumber: entry.key.week,
          incomes: entry.value,
          currencySymbol: currencySymbol,
        );
      },
    );
  }
}
