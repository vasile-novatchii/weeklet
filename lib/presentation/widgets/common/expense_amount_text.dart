import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

/// Text widget displaying expense amount with optional income styling
class ExpenseAmountText extends StatelessWidget {
  const ExpenseAmountText({
    super.key,
    required this.formattedAmount,
    this.tooltipMessage,
    this.isIncome = false,
  });

  final String formattedAmount;
  final String? tooltipMessage;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? Colors.green : context.colorScheme.onSurface;

    return EllipsisTooltipText(
      text: formattedAmount,
      tooltipMessage: tooltipMessage,
      textAlign: TextAlign.end,
      style: context.bodyLarge?.copyWith(
        fontWeight: .w600,
        color: color,
      ),
    );
  }
}
