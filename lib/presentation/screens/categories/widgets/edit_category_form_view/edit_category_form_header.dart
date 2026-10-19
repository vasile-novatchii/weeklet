import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class EditCategoryFormHeader extends StatelessWidget {
  const EditCategoryFormHeader({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        AppLocalizations.of(context).editCategorySheetTitle,
        style: context.titleLarge,
      ),
      IconButton(
        onPressed: onClose,
        icon: Icon(
          Icons.close,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
