import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/ellipsis_tooltip_text.dart';

/// Row displaying weekly total with label and formatted amount
class WeekTotalRow extends StatelessWidget {
  const WeekTotalRow({
    super.key,
    required this.formattedTotal,
    this.amountColor,
  });

  final String formattedTotal;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: .spaceBetween,
    children: [
      Text(
        AppLocalizations.of(context).weekTotalLabel,
        style: context.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      Flexible(
        child: EllipsisTooltipText(
          text: formattedTotal,
          style: context.bodyLarge?.copyWith(
            fontWeight: .w600,
            color: amountColor ?? context.colorScheme.primary,
          ),
        ),
      ),
    ],
  );
}
