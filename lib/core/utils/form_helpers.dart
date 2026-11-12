import 'package:flutter/material.dart';

/// Helper utilities for form data processing
class FormHelpers {
  FormHelpers._();

  /// Safely parses a string to double
  ///
  /// Returns the parsed value or null if parsing fails
  static double? parseAmount(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  /// Validates form and additional custom validations
  ///
  /// Returns true if all validations pass
  static bool validateForm(
    GlobalKey<FormState> formKey,
    List<bool Function()> customValidations,
  ) {
    final formValid = formKey.currentState?.validate() ?? false;
    final allCustomValid = customValidations.every((validation) => validation());
    return formValid && allCustomValid;
  }
}
