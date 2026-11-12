import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/theme/sizes.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class CategoryFormCancelButton extends StatelessWidget {
  const CategoryFormCancelButton({
    super.key,
    required this.isLoading,
    required this.onCancel,
  });

  final bool isLoading;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton(
      onPressed: isLoading ? null : onCancel,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(kButtonHeight),
        backgroundColor: context.colorScheme.outline,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      child: Text(
        l10n.cancelButtonLabel,
        style: TextStyle(
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}
