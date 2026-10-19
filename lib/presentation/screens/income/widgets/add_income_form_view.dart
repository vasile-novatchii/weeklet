import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/income/widgets/add/income_form_submit_view.dart';
import 'package:weeklet/presentation/widgets/common/form/export.dart';

class AddIncomeFormView extends StatefulWidget {
  const AddIncomeFormView({super.key});

  @override
  State<AddIncomeFormView> createState() => _AddIncomeFormViewState();
}

class _AddIncomeFormViewState extends State<AddIncomeFormView> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
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

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    context.read<IncomeBloc>().add(
      AddIncomeStarted(
        amount: _amountController.text,
        description: _descriptionController.text.trim(),
        date: _selectedDate ?? DateTime.now(),
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  SheetHeaderView(title: l10n.addIncomeSheetTitle),
                  AmountFieldView(
                    controller: _amountController,
                    currencySymbol: currencySymbol,
                  ),
                  DescriptionFieldView(
                    controller: _descriptionController,
                    hintText: l10n.incomeDescriptionFieldHint,
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
          bottomNavigationBar: IncomeFormSubmitView(
            onPressed: _onSave,
            isEnabled: _hasInteracted,
          ),
        ),
      ),
    );
  }
}
