import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/utils/income_filter_utils.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

class IncomeTotalCard extends StatelessWidget {
  const IncomeTotalCard({
    super.key,
    required this.total,
    this.selectedMonth,
    this.currencySymbol = AppConstants.DEFAULT_CURRENCY,
  });

  final double total;
  final int? selectedMonth;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final monthName = selectedMonth != null
        ? IncomeFilterUtils.getMonthName(selectedMonth!).toLowerCase()
        : '';
    final formattedTotal = NumberFormatter.formatAmountWithSign(
      total,
      isIncome: true,
    );
    final label = selectedMonth != null
        ? l10n.incomeTotalForMonth(monthName)
        : l10n.incomeTotalAllMonths;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                label,
                style: context.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              EllipsisTooltipText(
                text: formattedTotal,
                style: context.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
