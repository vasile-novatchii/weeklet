import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/category_extensions.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/category.dart';

/// A circular avatar displaying a category icon
class CategoryIconCircle extends StatelessWidget {
  const CategoryIconCircle({
    super.key,
    required this.category,
    this.radius = 22,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
    this.useTransparentBackground = false,
    this.transparentAlpha = 0.15,
  });

  final Category? category;
  final double radius;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  /// If true, uses transparent background with colored icon (expense style)
  /// If false, uses solid background with white icon (category style)
  final bool useTransparentBackground;

  /// Alpha value for transparent background (0.0 to 1.0)
  final double transparentAlpha;

  @override
  Widget build(BuildContext context) {
    final iconData = category?.toCategoryIcon().icon ?? Icons.help_outline;
    final primaryColor = context.colorScheme.primary;

    // Determine background color
    final Color bgColor;
    if (backgroundColor != null) {
      bgColor = backgroundColor!;
    } else if (useTransparentBackground) {
      bgColor = primaryColor.withValues(alpha: transparentAlpha);
    } else {
      bgColor = primaryColor;
    }

    // Determine icon color
    final Color foregroundColor;
    if (iconColor != null) {
      foregroundColor = iconColor!;
    } else if (useTransparentBackground) {
      foregroundColor = primaryColor;
    } else {
      foregroundColor = Colors.white;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(
        iconData,
        size: iconSize,
        color: foregroundColor,
      ),
    );
  }
}
