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

const _invalidAmountKey = 'invalidAmount';
const _emptyDescriptionKey = 'emptyDescription';

class _AddIncomeFormViewState extends State<AddIncomeFormView> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  bool _hasInteracted = false;
  String? _formError;

  /// True from a Save tap until the bloc reports the outcome. Locks Save so a
  /// double tap cannot dispatch a second add/update while the use case runs.
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFormInteraction);
    _descriptionController.addListener(_onFormInteraction);
    _amountController.addListener(_clearAmountError);
    _descriptionController.addListener(_clearDescriptionError);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onFormInteraction);
    _descriptionController.removeListener(_onFormInteraction);
    _amountController.removeListener(_clearAmountError);
    _descriptionController.removeListener(_clearDescriptionError);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormInteraction() {
    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }
  }

  void _clearAmountError() {
    if (_formError == _invalidAmountKey) {
      setState(() => _formError = null);
    }
  }

  void _clearDescriptionError() {
    if (_formError == _emptyDescriptionKey) {
      setState(() => _formError = null);
    }
  }

  void _onSave() {
    if (_submitting) return;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() {
      _submitting = true;
      _formError = null;
    });

    // Clear first so a repeated identical failure still re-emits (Equatable
    // would otherwise swallow it).
    final bloc = context.read<IncomeBloc>();
    bloc.add(const ClearIncomeFormErrorRequested());
    bloc.add(
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

    final amountError = _formError == _invalidAmountKey
        ? l10n.errorInvalidAmount
        : null;
    final descriptionError = _formError == _emptyDescriptionKey
        ? l10n.errorEmptyDescription
        : null;
    final generalError =
        _formError != null && amountError == null && descriptionError == null
        ? l10n.errorGeneric
        : null;

    return BlocListener<IncomeBloc, IncomeState>(
      // Only react to the outcome of this form's own save: a reload started
      // elsewhere (initial load, pull-to-refresh, reset, retry) must not close
      // the sheet or surface an error here. A failed reload after the save
      // also closes the sheet - the screen behind it shows the load error.
      listenWhen: (prev, curr) =>
          _submitting &&
          ((prev is IncomeLoading &&
                  curr is IncomeSuccess &&
                  curr.formError == null) ||
              (curr is IncomeSuccess && curr.formError != null) ||
              curr is IncomeFailure),
      listener: (context, state) {
        if (!mounted) return;
        if (state case IncomeSuccess(formError: final error?)) {
          setState(() {
            _submitting = false;
            _formError = error;
          });
        } else {
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
                    errorText: amountError,
                  ),
                  DescriptionFieldView(
                    controller: _descriptionController,
                    hintText: l10n.incomeDescriptionFieldHint,
                    errorText: descriptionError,
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
            isEnabled: _hasInteracted && !_submitting,
            generalError: generalError,
          ),
        ),
      ),
    );
  }
}
