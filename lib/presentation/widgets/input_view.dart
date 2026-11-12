import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;

class InputView extends StatelessWidget {
  const InputView({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.errorText,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    autocorrect: false,
    readOnly: readOnly,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      errorText: errorText,
    ),
    validator: validator,
    onChanged: onChanged,
    onTap: onTap,
  );
}
