/// Form validation utilities for consistent validation across the app
class FormValidators {
  FormValidators._();

  /// Validates that a field is not empty
  ///
  /// Returns error message if validation fails, null otherwise
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  /// Validates amount format (positive number with optional decimal)
  ///
  /// Examples of valid formats: 10, 10.5, 100.50
  /// Examples of invalid formats: .5, 10., -10, abc
  ///
  /// Returns error message if validation fails, null otherwise
  static String? amountFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    // Regex that checks:
    // ^[0-9]+  -> must start with at least one digit (prevents .5)
    // (\.[0-9]+)? -> optional, a dot followed by at least one digit (prevents 5.)
    final regExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');

    if (!regExp.hasMatch(value)) {
      return 'Invalid format (e.g., 10.50)';
    }

    // Check if amount is positive
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  /// Validates minimum text length
  ///
  /// Returns error message if validation fails, null otherwise
  static String? minLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (value.length < minLength) {
      final name = fieldName ?? 'This field';
      return '$name must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum text length
  ///
  /// Returns error message if validation fails, null otherwise
  static String? maxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      final name = fieldName ?? 'This field';
      return '$name must not exceed $maxLength characters';
    }

    return null;
  }

  /// Combines multiple validators
  ///
  /// Returns the first error message encountered, or null if all pass
  ///
  /// Example:
  /// ```dart
  /// validator: FormValidators.compose([
  ///   (value) => FormValidators.required(value),
  ///   (value) => FormValidators.minLength(value, 3),
  /// ])
  /// ```
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) => (String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  };
}
