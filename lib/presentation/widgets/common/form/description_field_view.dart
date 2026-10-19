import 'package:flutter/material.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/input_view.dart';
import 'package:weeklet/presentation/widgets/label_view.dart';

class DescriptionFieldView extends StatelessWidget {
  const DescriptionFieldView({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        LabelView(
          text: l10n.descriptionFieldLabel,
        ),
        InputView(
          controller: controller,
          hintText: l10n.descriptionFieldHint,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
