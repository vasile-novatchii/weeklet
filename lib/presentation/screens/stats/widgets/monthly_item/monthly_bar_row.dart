import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

class MonthlyBarRow extends StatelessWidget {
  const MonthlyBarRow({
    super.key,
    required this.label,
    required this.amount,
    required this.maxAmount,
    required this.color,
    required this.currencySymbol,
  });

  final String label;
  final double amount;
  final double maxAmount;
  final Color color;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final value = maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0.0;
    final formattedAmount = NumberFormatter.formatCurrency(
      amount,
      currencySymbol,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: context.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Flexible(
                child: EllipsisTooltipText(
                  text: formattedAmount,
                  style: context.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
