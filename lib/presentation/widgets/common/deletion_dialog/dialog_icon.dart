import 'package:flutter/material.dart';

/// Widget for the dialog icon with circular background
class DialogIcon extends StatelessWidget {
  const DialogIcon({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 50,
    height: 50,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
    ),
  );
}
