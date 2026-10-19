import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class SelectedIcon extends StatelessWidget {
  const SelectedIcon(
    this.categoryIcon, {
    super.key,
  });

  final CategoryIcon? categoryIcon;

  @override
  Widget build(BuildContext context) => Ink(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: context.colorScheme.primary,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(
      categoryIcon?.icon ?? Icons.help_outline,
      size: 24,
      color: Colors.white,
      semanticLabel: AppLocalizations.of(
        context,
      ).selectedIconPreviewSemanticLabel,
    ),
  );
}
