import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class SelectedIconMeta extends StatelessWidget {
  const SelectedIconMeta(
    this.categoryIcon,
    this.categoryName, {
    super.key,
  });

  final CategoryIcon? categoryIcon;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryIcon?.label ?? l10n.noIconSelectedLabel,
          style: context.textTheme.bodyMedium,
        ),
        Text(
          categoryName?.isNotEmpty == true
              ? categoryName!
              : l10n.categoryNameNotSetLabel,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
