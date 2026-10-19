import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/core/utils/date_picker_config.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/widgets/input_view.dart';
import 'package:weeklet/presentation/widgets/label_view.dart';

class DateFieldView extends StatefulWidget {
  const DateFieldView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.errorText,
  });
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? errorText;

  @override
  State<DateFieldView> createState() => _DateFieldViewState();
}

class _DateFieldViewState extends State<DateFieldView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatted());
  }

  @override
  void didUpdateWidget(DateFieldView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Defer: updating the controller during build would notify the Form.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final text = _formatted();
      if (_controller.text != text) {
        _controller.text = text;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatted() => widget.selectedDate?.format(style: .long) ?? '';

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await DatePickerConfig.showExpenseDatePicker(
      context,
      initialDate: widget.selectedDate,
      locale: LocaleManager().currentLocale,
    );

    if (pickedDate != null) {
      widget.onDateSelected(pickedDate.toDateOnly());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        LabelView(text: l10n.dateFieldLabel),
        InputView(
          controller: _controller,
          hintText: l10n.dateFieldHint,
          readOnly: true,
          onTap: () => _selectDate(context),
          errorText: widget.errorText,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        ),
      ],
    );
  }
}
