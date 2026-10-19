import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/utils/category_icon_labels.dart';

class CategoryIconView extends StatelessWidget {
  const CategoryIconView({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final CategoryIcon icon;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedBgColor = context.colorScheme.primary;
    final unselectedBgColor = context.colorScheme.outline;
    final iconColor = isSelected
        ? context.colorScheme.onPrimary
        : context.colorScheme.onSurfaceVariant;

    return IconButton(
      onPressed: onSelected,
      icon: Icon(
        icon.icon,
        size: 32,
        color: iconColor,
      ),
      color: context.colorScheme.secondary,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: context.colorScheme.outline,
        ),
        backgroundColor: isSelected ? selectedBgColor : unselectedBgColor,
      ),
      tooltip: CategoryIconLabels.of(AppLocalizations.of(context), icon),
    );
  }
}
