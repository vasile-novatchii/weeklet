import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/income/widgets/edit_income_form_view/edit_income_form_footer.dart';
import 'package:weeklet/presentation/widgets/common/form/export.dart';
import 'package:weeklet/presentation/widgets/common/unsaved_changes_dialog.dart';

class EditIncomeFormView extends StatefulWidget {
  const EditIncomeFormView(this.income, {super.key});

  final Income income;

  @override
  State<EditIncomeFormView> createState() => _EditIncomeFormViewState();
}

class _EditIncomeFormViewState extends State<EditIncomeFormView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.income.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.income.description,
    );
    _selectedDate = widget.income.date;

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
        _amountController.text != widget.income.amount.toString();
    final descriptionChanged =
        _descriptionController.text.trim() != widget.income.description;
    final dateChanged = _selectedDate != widget.income.date;
    return amountChanged || descriptionChanged || dateChanged;
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

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    context.read<IncomeBloc>().add(
      UpdateIncomeStarted(
        Income(
          id: widget.income.id,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.trim(),
          date: _selectedDate ?? widget.income.date,
          createdAt: widget.income.createdAt,
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

    return BlocListener<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is IncomeSuccess && state.actionError == null) {
          context.pop();
        }
      },
      child: CallbackShortcuts(
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      SheetHeaderView(
                        title: l10n.editIncomeSheetTitle,
                        onClose: _handleClose,
                      ),
                      AmountFieldView(
                        controller: _amountController,
                        currencySymbol: currencySymbol,
                      ),
                      DescriptionFieldView(
                        controller: _descriptionController,
                      ),
                      DateFieldView(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                            _hasInteracted = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: EditIncomeFormFooter(
                onSave: _onSave,
                onCancel: _handleClose,
                isEnabled: _hasInteracted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
