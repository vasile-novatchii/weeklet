import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/core/di/service_locator.dart' show sl;
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_form_footer_view/category_form_footer_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_icons_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_name_view.dart';
import 'package:weeklet/presentation/screens/categories/widgets/selected_icon_view/selected_icon_view.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  late TextEditingController _nameController;
  late ValueNotifier<CategoryIcon?> _selectedIconNotifier;
  final _formKey = GlobalKey<FormState>();

  /// Indicates whether the form is in the process of finishing submission.
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedIconNotifier = ValueNotifier(null);
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

  void _saveCategory() {
    if (_formKey.currentState!.validate() &&
        _selectedIconNotifier.value != null) {
      setState(() => _isFinishing = true);
      sl<CategoryBloc>().add(
        AddCategoryEvent(
          name: _nameController.text.trim(),
          icon: _selectedIconNotifier.value!.name,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider<CategoryBloc>.value(
      value: sl<CategoryBloc>(),
      child: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategorySuccess) {
            final msg = switch (state.message) {
              'categoryAddedSuccess' => l10n.categoryAddedSuccess,
              'categoryUpdatedSuccess' => l10n.categoryUpdatedSuccess,
              'categoryDeletedSuccess' => l10n.categoryDeletedSuccess,
              _ => l10n.errorGeneric,
            };
            context.showSuccessSnackBar(msg);
            Future.delayed(
              const Duration(seconds: 2),
              () {
                if (context.mounted) {
                  context.pop();
                }
              },
            );
          }
          if (state is CategoryError) {
            setState(() => _isFinishing = false);
            final msg = switch (state.message) {
              'emptyName' => l10n.categoryNameValidationRequired,
              'errorCategoryNotFound' => l10n.errorCategoryNotFound,
              _ => l10n.errorGeneric,
            };
            context.showErrorSnackBar(msg);
          }
        },
        builder: (context, state) {
          final isLoading = state is CategoryLoading || _isFinishing;

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: !isLoading,
              title: Text(l10n.addCategoryScreenTitle),
            ),
            body: IgnorePointer(
              ignoring: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      CategoryName(controller: _nameController),
                      ValueListenableBuilder<CategoryIcon?>(
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
            ),
            bottomNavigationBar: CategoryFormFooterView(
              isLoading: isLoading,
              onSave: _saveCategory,
              onCancel: () => context.pop(),
              nameController: _nameController,
              selectedIconNotifier: _selectedIconNotifier,
            ),
          );
        },
      ),
    );
  }
}
