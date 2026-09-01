import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

/// Text widget displaying expense amount with optional income styling
class ExpenseAmountText extends StatelessWidget {
  const ExpenseAmountText({
    super.key,
    required this.formattedAmount,
    this.isIncome = false,
  });

  final String formattedAmount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? Colors.green : context.colorScheme.onSurface;

    return EllipsisTooltipText(
      text: formattedAmount,
      style: context.bodyLarge?.copyWith(
        fontWeight: .w600,
        color: color,
      ),
    );
  }
}
