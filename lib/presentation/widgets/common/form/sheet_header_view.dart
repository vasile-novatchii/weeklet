import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class SheetHeaderView extends StatelessWidget {
  const SheetHeaderView({
    super.key,
    this.title,
    this.onClose,
  });

  final String? title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolvedTitle = title ?? l10n.addExpenseSheetTitle;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          resolvedTitle,
          style: context.titleLarge,
        ),
        IconButton(
          onPressed: onClose ?? () => context.pop(true),
          icon: Icon(
            Icons.close,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
