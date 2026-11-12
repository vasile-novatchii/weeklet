import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/di/service_locator.dart' show sl;
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/form_helpers.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/utils/default_category_selection.dart';
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

  /// Guards the D-10 auto-select so it applies at most once per form instance.
  bool _autoSelectConsumed = false;

  /// Guards the default-category preselect so it applies at most once.
  bool _defaultPreselectConsumed = false;

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

  /// Pre-selects a category the user created mid-flow (D-10), so the
  /// no-category fallback never fires right after they made their own
  /// category. Never overrides a manual selection and never fires twice.
  void _onCategoryChanged(BuildContext context, CategoryState state) {
    if (_selectedCategory != null) return;
    if (state is! CategoriesLoaded) return;

    final createdId = state.lastCreatedCategoryId;
    if (_autoSelectConsumed || createdId == null) {
      _preselectDefault(state);
      return;
    }

    final matches = state.categories.where((c) => c.id == createdId);
    if (matches.isEmpty) {
      _preselectDefault(state);
      return;
    }

    setState(() {
      _selectedCategory = matches.first;
    });
    _autoSelectConsumed = true;
    context.read<CategoryBloc>().add(const ClearLastCreatedCategoryRequested());
  }

  /// Pre-selects the default category while it is the only category.
  /// Does not mark the form as interacted (Save stays disabled until the user
  /// touches a field).
  void _preselectDefault(CategoriesLoaded state) {
    if (_defaultPreselectConsumed) return;
    final id = DefaultCategorySelection.preselectedCategoryId(
      state.categories,
      state.defaultCategoryId,
    );
    if (id == null) return;
    final matches = state.categories.where((c) => c.id == id);
    if (matches.isEmpty) return;
    setState(() => _selectedCategory = matches.first);
    _defaultPreselectConsumed = true;
  }

  void _onSave() {
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

    context.read<ExpenseBloc>().add(
      AddExpenseStarted(
        amount: _amountController.text,
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory?.id,
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

    return MultiBlocListener(
      listeners: [
        BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseSuccess && state.actionError == null) {
              context.pop();
            }
          },
        ),
        BlocListener<CategoryBloc, CategoryState>(
          listener: _onCategoryChanged,
        ),
      ],
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
                    hintText: AppLocalizations.of(context).descriptionFieldHint,
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
