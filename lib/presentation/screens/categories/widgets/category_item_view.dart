import 'package:flutter/material.dart';
import 'package:weeklet/core/di/service_locator.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/screens/categories/widgets/edit_category_form_view/edit_category_form_view.dart';
import 'package:weeklet/presentation/widgets/common/category_icon_circle.dart';
import 'package:weeklet/presentation/widgets/common/category_name_text.dart';
import 'package:weeklet/presentation/widgets/common/common_menu_button.dart';
import 'package:weeklet/presentation/widgets/common/deletion_dialog/deletion_dialog.dart';

class CategoryItemView extends StatelessWidget {
  const CategoryItemView(
    this.category, {
    super.key,
  });

  final Category category;

  void _deleteCategory(BuildContext context) {
    sl<CategoryBloc>().add(DeleteCategoryEvent(id: category.id));
  }

  void _editCategory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SizedBox(
          height: context.screenHeight * 0.8,
          child: EditCategoryFormView(category),
        ),
      ),
    );
  }

  List<MenuItem> _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      MenuItem(
        label: l10n.editMenuLabel,
        icon: Icons.edit,
        onPressed: () => _editCategory(context),
        semanticLabel: l10n.editCategorySemanticLabel,
      ),
      MenuItem(
        label: l10n.deleteMenuLabel,
        icon: Icons.delete,
        iconColor: context.colorScheme.error,
        textColor: context.colorScheme.error,
        overlayColor: context.colorScheme.error,
        onPressed: () => CustomConfirmationDialog.show(
          context: context,
          icon: Icons.delete,
          iconBackgroundColor: context.colorScheme.error,
          title: l10n.deleteCategoryDialogTitle,
          subtitle1: l10n.deleteConfirmSubtitle1,
          subtitle1AccentText: ' ${category.name}?',
          subtitle2: l10n.actionCannotBeUndone,
          confirmButtonColor: context.colorScheme.error,
          onConfirm: () => _deleteCategory(context),
          confirmButtonTextColor: Colors.white,
          confirmButtonText: l10n.deleteButtonLabel,
          cancelButtonColor: context.colorScheme.outline,
          cancelButtonTextColor: context.colorScheme.onSurface,
          cancelButtonText: l10n.cancelButtonLabel,
        ),
        semanticLabel: l10n.deleteCategorySemanticLabel,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Card(
        semanticContainer: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 80,
            maxHeight: 120,
            minWidth: double.infinity,
          ),
          child: Tooltip(
            message: category.name,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                CategoryIconCircle(category: category),
                CategoryNameText(name: category.name),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        right: 5,
        top: 5,
        child: CommonMenuButton(
          menuItems: _buildMenuItems(context),
          iconSize: 16,
        ),
      ),
    ],
  );
}
