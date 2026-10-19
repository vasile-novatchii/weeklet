import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/extensions/context_extensions.dart';
import 'package:weeklet/core/theme/sizes.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/common/form/sheet_footer_padding.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';

class IncomeFormSubmitView extends StatelessWidget {
  const IncomeFormSubmitView({
    super.key,
    required this.onPressed,
    this.isEnabled = false,
    this.generalError,
  });

  final VoidCallback onPressed;
  final bool isEnabled;
  final String? generalError;

  @override
  Widget build(BuildContext context) => BlocBuilder<IncomeBloc, IncomeState>(
    builder: (context, state) {
      final l10n = AppLocalizations.of(context);
      final isLoading = state is IncomeLoading;
      final canSubmit = isEnabled && !isLoading;

      final button = ElevatedButton(
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
              l10n.saveIncomeButtonLabel,
              style: const TextStyle(color: Colors.white),
            ),
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ),
      );

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isLoading ? 0.6 : 1.0,
        child: SheetFooterPadding(
          child: generalError == null
              ? button
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: context.colorScheme.error,
                          ),
                          Expanded(
                            child: Text(
                              generalError!,
                              style: context.bodyMedium?.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    button,
                  ],
                ),
        ),
      );
    },
  );
}
