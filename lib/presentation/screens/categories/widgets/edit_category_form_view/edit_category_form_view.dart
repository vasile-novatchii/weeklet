import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/extensions/category_extensions.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_form_footer_view/category_form_footer_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_icons_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_name_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/edit_category_form_view/edit_category_form_header.dart';
import 'package:weeklet/presentation/screens/categories/widgets/selected_icon_view/selected_icon_view.dart';
import 'package:weeklet/presentation/widgets/common/unsaved_changes_dialog.dart';

class EditCategoryFormView extends StatefulWidget {
  const EditCategoryFormView(
    this.category, {
    super.key,
  });

  final Category category;

  @override
  State<EditCategoryFormView> createState() => _EditCategoryFormViewState();
}

class _EditCategoryFormViewState extends State<EditCategoryFormView> {
  late TextEditingController _nameController;
  late ValueNotifier<CategoryIcon?> _selectedIconNotifier;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category.name,
    );
    _selectedIconNotifier = ValueNotifier(
      widget.category.toCategoryIcon(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _selectedIconNotifier.dispose();
    super.dispose();
  }

  void _onIconSelected(CategoryIcon icon) {
    _selectedIconNotifier.value = icon;
  }

  bool _hasUnsavedChanges() {
    final nameChanged = _nameController.text.trim() != widget.category.name;
    final iconChanged =
        _selectedIconNotifier.value?.name != widget.category.icon;
    return nameChanged || iconChanged;
  }

  Future<void> _handleClose() async {
    if (_hasUnsavedChanges()) {
      final shouldDiscard = await UnsavedChangesDialog.show(context);
      if (shouldDiscard && mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }

  void _updateCategory() {
    if (_formKey.currentState!.validate() &&
        _selectedIconNotifier.value != null) {
      context.read<CategoryBloc>().add(
        UpdateCategoryEvent(
          name: _nameController.text.trim(),
          icon: _selectedIconNotifier.value!.name,
          id: widget.category.id,
          createdAt: widget.category.createdAt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategorySuccess) {
          if (context.mounted) {
            context.pop();
          }
        }
        if (state is CategoryError) {
          final msg = switch (state.message) {
            'emptyName' => l10n.categoryNameValidationRequired,
            'errorCategoryNotFound' => l10n.errorCategoryNotFound,
            _ => l10n.errorGeneric,
          };
          context.showErrorSnackBar(msg);
        }
      },
      builder: (context, state) {
        final isLoading = state is CategoryLoading;

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.escape): _handleClose,
          },
          child: Focus(
            autofocus: true,
            child: GestureDetector(
              onTap: context.unfocus,
              child: Scaffold(
                body: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 24,
                  ),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        EditCategoryFormHeader(onClose: _handleClose),
                        CategoryName(controller: _nameController),
                        ValueListenableBuilder(
                          valueListenable: _selectedIconNotifier,
                          builder: (context, selectedIcon, ___) =>
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _nameController,
                                builder: (context, searchTerm, ___) =>
                                    SelectedIconView(
                                      selectedIcon: selectedIcon,
                                      categoryName: searchTerm.text,
                                    ),
                              ),
                        ),
                        CategoryIconsView(
                          onIconSelected: _onIconSelected,
                          selectedIconNotifier: _selectedIconNotifier,
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: CategoryFormFooterView(
                  isLoading: isLoading,
                  onSave: _updateCategory,
                  onCancel: _handleClose,
                  nameController: _nameController,
                  selectedIconNotifier: _selectedIconNotifier,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
