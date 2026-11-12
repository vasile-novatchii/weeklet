import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// A confirmation dialog that asks the user if they want to discard unsaved changes.
///
/// Returns `true` if the user confirms they want to leave without saving,
/// returns `false` if they want to stay and continue editing.
class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.discardChangesDialogTitle),
      content: Text(l10n.unsavedChangesDialogContent),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(l10n.cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => context.pop(true),
          style: TextButton.styleFrom(
            foregroundColor: context.colorScheme.error,
          ),
          child: Text(l10n.discardButtonLabel),
        ),
      ],
    );
  }

  /// Shows the unsaved changes dialog and returns a `Future<bool>`.
  ///
  /// Returns `true` if the user wants to discard changes and leave,
  /// returns `false` if they want to stay.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const UnsavedChangesDialog(),
    );
    return result ?? false;
  }
}
