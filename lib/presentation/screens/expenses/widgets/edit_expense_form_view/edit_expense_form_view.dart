import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/utils/form_helpers.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/add/export.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/edit_expense_form_view/edit_expense_form_footer.dart';
import 'package:weeklet/presentation/widgets/common/unsaved_changes_dialog.dart';

class EditExpenseFormView extends StatefulWidget {
  const EditExpenseFormView(this.expense, {super.key});

  final Expense expense;

  @override
  State<EditExpenseFormView> createState() => _EditExpenseFormViewState();
}

class _EditExpenseFormViewState extends State<EditExpenseFormView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  Category? _selectedCategory;
  DateTime? _selectedDate;
  String? _dateError;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _selectedDate = widget.expense.createdAt;

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

  bool _hasUnsavedChanges() {
    final amountChanged =
        _amountController.text != widget.expense.amount.toString();
    final descriptionChanged =
        _descriptionController.text.trim() != widget.expense.description;
    final categoryChanged = _selectedCategory?.id != widget.expense.categoryId;
    final dateChanged = _selectedDate != widget.expense.createdAt;
    return amountChanged || descriptionChanged || categoryChanged || dateChanged;
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

  bool _validateDate() {
    if (_selectedDate == null) {
      final l10n = AppLocalizations.of(context);
      setState(() => _dateError = l10n.dateValidationRequired);
      return false;
    }
    setState(() => _dateError = null);
    return true;
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
      UpdateExpenseStarted(
        Expense(
          id: widget.expense.id,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategory!.id,
          createdAt: _selectedDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
          if (categoryState is CategoriesLoaded && _selectedCategory == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final category = categoryState.categories.firstWhere(
                  (cat) => cat.id == widget.expense.categoryId,
                  orElse: () => categoryState.categories.first,
                );
                setState(() => _selectedCategory = category);
              }
            });
          }

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
                      autovalidateMode: _autovalidateMode,
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 20,
                        children: [
                          SheetHeaderView(
                            title: l10n.editExpenseSheetTitle,
                            onClose: _handleClose,
                          ),
                          AmountFieldView(
                            controller: _amountController,
                            currencySymbol: currencySymbol,
                          ),
                          DescriptionFieldView(
                            controller: _descriptionController,
                            hintText: l10n.descriptionFieldHint,
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
                  bottomNavigationBar: EditExpenseFormFooter(
                    onSave: _onSave,
                    onCancel: _handleClose,
                    isEnabled: _hasInteracted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
