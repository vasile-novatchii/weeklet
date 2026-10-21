import 'package:flutter/material.dart';

/// Standard settings list tile with consistent styling.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    leading: leading,
    title: Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        : null,
    trailing: trailing,
    onTap: onTap,
  );
}
