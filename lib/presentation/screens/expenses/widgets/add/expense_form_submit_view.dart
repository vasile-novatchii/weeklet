import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/theme/sizes.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/form/sheet_footer_padding.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';

class ExpenseFormSubmitView extends StatelessWidget {
  const ExpenseFormSubmitView({
    super.key,
    required this.onPressed,
    this.isEnabled = false,
  });

  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        final isLoading = state is ExpenseLoading;
        final canSubmit = isEnabled && !isLoading;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isLoading ? 0.6 : 1.0,
          child: SheetFooterPadding(
            child: ElevatedButton(
              onPressed: canSubmit ? onPressed : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(kButtonHeight),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: isLoading,
                  replacement: Text(
                    l10n.saveExpenseButtonLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
