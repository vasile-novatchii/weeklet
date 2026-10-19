import 'package:flutter/material.dart';

/// Configuration and utilities for date picking across the app
class DatePickerConfig {
  DatePickerConfig._();

  /// Minimum allowed date for expense dates
  static DateTime get minExpenseDate => DateTime(2020, 1, 1);

  /// Maximum allowed date for expense dates (1 year from now)
  static DateTime get maxExpenseDate =>
      DateTime.now().add(const Duration(days: 365));

  /// Locale used by the date picker for a given app locale.
  ///
  /// English maps to en_GB (Monday-first week, D-02); ro/ru follow the
  /// app language (D-05).
  static Locale pickerLocale(Locale appLocale) =>
      appLocale.languageCode == 'en' ? const Locale('en', 'GB') : appLocale;

  /// Shows a date picker dialog with expense-specific configuration
  ///
  /// Returns the selected date or null if cancelled
  static Future<DateTime?> showExpenseDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    Locale? locale,
  }) async => showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: minExpenseDate,
    lastDate: maxExpenseDate,
    locale: locale,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    barrierDismissible: false,
  );
}
