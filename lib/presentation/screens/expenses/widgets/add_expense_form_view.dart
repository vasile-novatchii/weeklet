import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/di/service_locator.dart' show sl;
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/form_helpers.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/add/export.dart';

class AddExpenseFormView extends StatefulWidget {
  const AddExpenseFormView({super.key});

  @override
  State<AddExpenseFormView> createState() => _AddExpenseFormViewState();
}

class _AddExpenseFormViewState extends State<AddExpenseFormView> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Category? _selectedCategory;
  DateTime? _selectedDate;
  String? _dateError;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    sl<CategoryBloc>().add(const GetAllCategoriesEvent());
    _amountController.addListener(_onFormInteraction);
    _descriptionController.addListener(_onFormInteraction);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onFormInteraction);
    _descriptionController.removeListener(_onFormInteraction);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormInteraction() {
    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }
  }

  bool _validateDate() {
    if (_selectedDate == null) {
      final l10n = AppLocalizations.of(context);
      setState(() => _dateError = l10n.dateValidationRequired);
      return false;
    }
    setState(() => _dateError = null);
    return true;
  }

  Future<void> _onSave() async {
    final isValid = FormHelpers.validateForm(
      _formKey,
      [_validateDate],
    );

    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    String? finalCategoryId = _selectedCategory?.id;

    if (finalCategoryId == null) {
      final categoryState = context.read<CategoryBloc>().state;
      if (categoryState is CategoriesLoaded) {
        final dailyCategory = categoryState.categories
            .where((c) => c.name.trim().toLowerCase() == 'daily')
            .firstOrNull;

        if (dailyCategory != null) {
          finalCategoryId = dailyCategory.id;
        } else {
          await sl<AddCategoryUseCase>().call(
            AddCategoryParams(
              name: 'Daily',
              icon: 'home',
              createdAt: DateTime.now(),
            ),
          );
          final updatedCategories =
              await sl<GetAllCategoriesUseCase>().call(NoParams());
          final created = updatedCategories.firstWhere(
            (c) => c.name.trim().toLowerCase() == 'daily',
          );
          finalCategoryId = created.id;

          if (mounted) {
            context.read<CategoryBloc>().add(const GetAllCategoriesEvent());
          }
        }
      } else {
        await sl<AddCategoryUseCase>().call(
          AddCategoryParams(
            name: 'Daily',
            icon: 'home',
            createdAt: DateTime.now(),
          ),
        );
        final updatedCategories =
            await sl<GetAllCategoriesUseCase>().call(NoParams());
        final created = updatedCategories.firstWhere(
          (c) => c.name.trim().toLowerCase() == 'daily',
        );
        finalCategoryId = created.id;

        if (mounted) {
          context.read<CategoryBloc>().add(const GetAllCategoriesEvent());
        }
      }
    }

    if (!mounted) return;

    context.read<ExpenseBloc>().add(
      AddExpenseStarted(
        amount: _amountController.text,
        description: _descriptionController.text.trim(),
        categoryId: finalCategoryId,
        defaultCategoryName: AppLocalizations.of(context).defaultCategoryName,
        date: _selectedDate!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsBloc>().state;
    final currencySymbol = settingsState is SettingsLoaded
        ? settingsState.currencySymbol
        : AppConstants.DEFAULT_CURRENCY;

    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseSuccess && state.actionError == null) {
          context.pop();
        }
      },
      child: GestureDetector(
        onTap: context.unfocus,
        child: Scaffold(
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 24,
            ),
            child: Form(
              autovalidateMode: _autovalidateMode,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  const SheetHeaderView(),
                  AmountFieldView(
                    controller: _amountController,
                    currencySymbol: currencySymbol,
                  ),
                  DescriptionFieldView(
                    controller: _descriptionController,
                  ),
                  ExpenseFormCategoryView(
                    selectedCategory: _selectedCategory,
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                        _hasInteracted = true;
                      });
                    },
                  ),
                  DateFieldView(
                    selectedDate: _selectedDate,
                    errorText: _dateError,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _dateError = null;
                        _hasInteracted = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ExpenseFormSubmitView(
            onPressed: _onSave,
            isEnabled: _hasInteracted,
          ),
        ),
      ),
    );
  }
}
