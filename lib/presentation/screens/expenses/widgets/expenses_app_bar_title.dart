import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// AppBar title with an optional income subtitle for the selected period.
class ExpensesAppBarTitle extends StatelessWidget {
  const ExpensesAppBarTitle({
    super.key,
    required this.title,
    required this.currencySymbol,
    this.incomeTotal,
  });

  final String title;
  final String currencySymbol;
  final double? incomeTotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = incomeTotal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        if (total != null)
          Text(
            l10n.homeIncomeSubtitle(
              NumberFormatter.formatCurrency(total, currencySymbol),
            ),
            style: context.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).appBarTheme.foregroundColor?.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
