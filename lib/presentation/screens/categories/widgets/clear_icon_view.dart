import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';

class ClearSearchButton extends StatelessWidget {
  const ClearSearchButton({
    required this.onClearNotifier,
    required this.onClearController,
    this.iconColor,
    super.key,
  });

  final VoidCallback onClearNotifier;
  final VoidCallback onClearController;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () {
      onClearNotifier();
      onClearController();
    },
    icon: Icon(
      Icons.clear,
      size: 20,
      color: iconColor ?? context.colorScheme.surfaceContainerHighest,
    ),
    style: IconButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: const Size(24, 24),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
    ),
  );
}
