import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/utils/expense_filter_utils.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/utils/monthly_snapshot_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/stats/widgets/monthly_item/monthly_bar_row.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

class MonthlyItem extends StatelessWidget {
  const MonthlyItem({
    super.key,
    required this.snapshot,
    required this.maxIncome,
    required this.currencySymbol,
  });

  final MonthlySnapshot snapshot;
  final double maxIncome;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monthName = ExpenseFilterUtils.getMonthAbbreviation(snapshot.month);
    final balanceText = NumberFormatter.formatCurrency(
      snapshot.balance,
      currencySymbol,
    );
    final balanceColor =
        MonthlySnapshotUtils.isBalancePositive(snapshot.balance)
        ? context.theme.appBarTheme.backgroundColor
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month name and balance header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthName,
                style: context.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Flexible(
                child: EllipsisTooltipText(
                  text: balanceText,
                  style: context.labelMedium?.copyWith(
                    color: balanceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MonthlyBarRow(
            label: l10n.incomeBarLabel,
            amount: snapshot.totalIncome,
            maxAmount: maxIncome,
            color: context.successColor,
            currencySymbol: currencySymbol,
          ),
          MonthlyBarRow(
            label: l10n.expensesBarLabel,
            amount: snapshot.totalExpenses,
            maxAmount: maxIncome,
            color: context.colorScheme.error,
            currencySymbol: currencySymbol,
          ),
        ],
      ),
    );
  }
}
