import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/theme/sizes.dart';
import 'package:weeklet/l10n/app_localizations.dart';

class CategoryFormSaveButton extends StatelessWidget {
  const CategoryFormSaveButton({
    super.key,
    required this.isLoading,
    required this.onSave,
    required this.nameController,
    required this.selectedIconNotifier,
  });

  final bool isLoading;
  final VoidCallback onSave;
  final TextEditingController nameController;
  final ValueNotifier<CategoryIcon?> selectedIconNotifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: nameController,
      builder: (context, nameValue, ___) =>
          ValueListenableBuilder<CategoryIcon?>(
            valueListenable: selectedIconNotifier,
            builder: (context, selectedIcon, ___) {
              final isEnabled =
                  nameValue.text.trim().isNotEmpty && selectedIcon != null;

              return ElevatedButton(
                onPressed: isLoading || !isEnabled ? null : onSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(kButtonHeight),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Text(
                          l10n.saveButtonLabel,
                          style: TextStyle(
                            color: isEnabled ? Colors.white : Colors.white70,
                          ),
                        ),
                ),
              );
            },
          ),
    );
  }
}
