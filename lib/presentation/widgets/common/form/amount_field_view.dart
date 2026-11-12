import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/input_view.dart';
import 'package:weeklet/presentation/widgets/label_view.dart';

class AmountFieldView extends StatelessWidget {
  const AmountFieldView({
    super.key,
    required this.controller,
    required this.currencySymbol,
    this.errorText,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        LabelView(
          text: l10n.amountFieldLabel(currencySymbol),
        ),
        InputView(
          controller: controller,
          hintText: l10n.amountFieldHint,
          errorText: errorText,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return l10n.validationRequired;
            final regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');
            if (!regExp.hasMatch(value)) {
              return l10n.validationInvalidAmountFormat;
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return l10n.validationAmountMustBePositive;
            }
            return null;
          },
        ),
      ],
    );
  }
}
