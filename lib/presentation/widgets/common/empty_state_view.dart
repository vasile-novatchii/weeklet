import 'package:flutter/material.dart';

/// A reusable empty state widget with icon and messages
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 64,
    this.iconColor = Colors.grey,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const .symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: .center,
        spacing: 8,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: iconColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: iconColor,
            ),
          ),
        ],
      ),
    ),
  );
}
