import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// Menu item configuration for CommonMenuButton
class MenuItem {
  const MenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.iconColor,
    this.textColor,
    this.overlayColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? semanticLabel;
  final Color? iconColor;
  final Color? textColor;
  final Color? overlayColor;
}

/// A reusable menu button with three vertical dots
///
/// Displays a menu anchor with customizable menu items
class CommonMenuButton extends StatelessWidget {
  const CommonMenuButton({
    super.key,
    required this.menuItems,
    this.iconSize = 20,
    this.tooltip,
  });

  final List<MenuItem> menuItems;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolvedTooltip = tooltip ?? l10n.moreOptionsTooltip;
    return MenuAnchor(
      alignmentOffset: const Offset(-65, 4),
      consumeOutsideTap: true,
      builder: (context, controller, ___) => IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tooltip: resolvedTooltip,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: Icon(
          Icons.more_vert,
          size: iconSize,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      menuChildren: menuItems
          .map(
            (item) => MenuItemButton(
              onPressed: item.onPressed,
              semanticsLabel: item.semanticLabel ?? item.label,
              leadingIcon: Icon(
                item.icon,
                size: 16,
                color: item.iconColor,
              ),
              style: item.overlayColor != null
                  ? TextButton.styleFrom(overlayColor: item.overlayColor)
                  : null,
              child: Text(
                item.label,
                style: item.textColor != null
                    ? TextStyle(color: item.textColor)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
