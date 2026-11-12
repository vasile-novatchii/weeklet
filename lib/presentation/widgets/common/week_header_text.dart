import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// Header text for displaying week number
class WeekHeaderText extends StatelessWidget {
  const WeekHeaderText({
    super.key,
    required this.weekNumber,
  });

  final int weekNumber;

  @override
  Widget build(BuildContext context) => Text(
    AppLocalizations.of(context).weekHeaderLabel(weekNumber),
    style: context.titleMedium?.copyWith(
      fontWeight: .w400,
      color: context.colorScheme.onSurfaceVariant,
    ),
  );
}
