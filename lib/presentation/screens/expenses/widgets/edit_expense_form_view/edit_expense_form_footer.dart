import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/theme/sizes.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/form/sheet_footer_padding.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';

class EditExpenseFormFooter extends StatelessWidget {
  const EditExpenseFormFooter({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.isEnabled,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;
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
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(kButtonHeight),
                      backgroundColor: context.colorScheme.outline,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.cancelButtonLabel,
                      style: TextStyle(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canSubmit ? onSave : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Visibility(
                        visible: isLoading,
                        replacement: Text(
                          l10n.saveButtonLabel,
                          style: const TextStyle(color: Colors.white),
                        ),
                        child: const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
