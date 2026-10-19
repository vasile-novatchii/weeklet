import 'package:flutter/material.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_form_footer_view/category_form_cancel_button.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_form_footer_view/category_form_save_button.dart';
import 'package:weeklet/presentation/widgets/common/form/sheet_footer_padding.dart';

class CategoryFormFooterView extends StatelessWidget {
  const CategoryFormFooterView({
    super.key,
    required this.isLoading,
    required this.onSave,
    required this.onCancel,
    required this.nameController,
    required this.selectedIconNotifier,
  });

  /// Whether the form is currently in a loading state.
  final bool isLoading;

  /// Callback invoked when the Save button is pressed.
  final VoidCallback onSave;

  /// Callback invoked when the Cancel button is pressed.
  final VoidCallback onCancel;

  /// The controller for the category name input.
  final TextEditingController nameController;

  /// The notifier for the selected icon.
  final ValueNotifier<CategoryIcon?> selectedIconNotifier;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: isLoading ? 0.6 : 1.0,
    child: SheetFooterPadding(
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: CategoryFormCancelButton(
              isLoading: isLoading,
              onCancel: onCancel,
            ),
          ),
          Expanded(
            child: CategoryFormSaveButton(
              isLoading: isLoading,
              onSave: onSave,
              nameController: nameController,
              selectedIconNotifier: selectedIconNotifier,
            ),
          ),
        ],
      ),
    ),
  );
}
