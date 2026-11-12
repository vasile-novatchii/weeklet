import 'package:flutter/material.dart';
import 'package:weeklet/core/extensions/date_time_extensions.dart';
import 'package:weeklet/core/utils/locale_manager.dart';

class LocaleDate {
  // singleton
  LocaleDate._privateConstructor();
  static final LocaleDate instance = LocaleDate._privateConstructor();

  // ============ METHOD 1: Get Current Locale String ============

  /// Get current device locale as string
  ///
  /// **Returns:**
  /// Locale string like "en_US", "ro_RO", "ru_RU"
  ///
  /// **Usage:**
  /// ```dart
  /// String locale = LocaleManager().currentLocaleString;
  /// print(locale); // "en_US" or "ro_RO" depending on device
  /// ```
  static String getLocaleString() => LocaleManager().currentLocaleString;

  // ============ METHOD 2: Get Current Locale Object ============

  /// Get current device locale as Locale object
  ///
  /// **Returns:**
  /// Locale object with languageCode and countryCode
  ///
  /// **Usage:**
  /// ```dart
  /// Locale locale = LocaleManager().currentLocale;
  /// print(locale.languageCode); // "en"
  /// print(locale.countryCode);  // "US"
  /// ```
  static Locale getLocaleObject() => LocaleManager().currentLocale;

  // ============ METHOD 3: Format Date with Current Locale ============

  /// Format date using device's current locale
  ///
  /// **Usage:**
  /// ```dart
  /// DateTime date = DateTime.now();
  /// String formatted = date.format();
  /// // en_US -> "Jan 15, 2026"
  /// // ro_RO -> "ian. 15, 2026"
  /// // ru_RU -> "15 янв. 2026 г."
  /// ```
  static String getFormattedDateInLocale(
    DateTime date, {
    DateFormatStyle style = DateFormatStyle.medium,
  }) => date.format(style: style);

  // ============ METHOD 4: Get Locale Date with Different Styles ============

  /// Get date formatted in different styles based on current locale
  ///
  /// **Usage:**
  /// ```dart
  /// DateTime date = DateTime(2026, 1, 15);
  ///
  /// print(date.format(style: DateFormatStyle.short));
  /// // en_US -> "1/15/26"
  /// // ro_RO -> "15.01.26"
  ///
  /// print(date.format(style: DateFormatStyle.medium));
  /// // en_US -> "Jan 15, 2026"
  /// // ro_RO -> "ian. 15, 2026"
  ///
  /// print(date.format(style: DateFormatStyle.long));
  /// // en_US -> "January 15, 2026"
  /// // ro_RO -> "15 ianuarie 2026"
  ///
  /// print(date.format(style: DateFormatStyle.full));
  /// // en_US -> "Thursday, January 15, 2026"
  /// // ro_RO -> "joi, 15 ianuarie 2026"
  /// ```
  static Map<String, String> getDateInAllStyles(DateTime date) => {
    'short': date.format(style: DateFormatStyle.short),
    'medium': date.format(style: DateFormatStyle.medium),
    'long': date.format(style: DateFormatStyle.long),
    'full': date.format(style: DateFormatStyle.full),
  };

  // ============ METHOD 5: Get Localized Month Name ============

  /// Get month name in current device locale
  ///
  /// **Usage:**
  /// ```dart
  /// DateTime date = DateTime(2026, 1, 15);
  ///
  /// print(date.getMonthName());
  /// // en_US -> "January"
  /// // ro_RO -> "ianuarie"
  /// // ru_RU -> "январь"
  ///
  /// print(date.getMonthName(abbreviated: true));
  /// // en_US -> "Jan"
  /// // ro_RO -> "ian."
  /// // ru_RU -> "янв."
  /// ```
  static String getLocalizedMonthName(
    DateTime date, {
    bool abbreviated = false,
  }) =>
      abbreviated ? date.getMonthName(abbreviated: true) : date.getMonthName();

  // ============ METHOD 6: Get Localized Weekday Name ============

  /// Get weekday name in current device locale
  ///
  /// **Usage:**
  /// ```dart
  /// DateTime date = DateTime(2026, 1, 15);
  ///
  /// print(date.getWeekdayName());
  /// // en_US -> "Thursday"
  /// // ro_RO -> "joi"
  /// // ru_RU -> "четверг"
  ///
  /// print(date.getWeekdayName(abbreviated: true));
  /// // en_US -> "Thu"
  /// // ro_RO -> "joi"
  /// // ru_RU -> "чт"
  /// ```
  static String getLocalizedWeekdayName(
    DateTime date, {
    bool abbreviated = false,
  }) => abbreviated
      ? date.getWeekdayName(abbreviated: true)
      : date.getWeekdayName();

  // ============ METHOD 7: Get Locale Info String ============

  /// Get formatted locale info string
  ///
  /// **Returns:**
  /// String like "en_US", "Romanian (Romania)", "Russian (Russia)"
  ///
  /// **Usage:**
  /// ```dart
  /// String info = getLocaleInfo();
  /// // Returns: "en_US" or "ro_RO" etc.
  /// ```
  static String getLocaleInfo() => LocaleDate._getLocaleName(
    LocaleManager().currentLocaleString,
  );

  // ============ METHOD 8: Get Complete Locale Date Info ============

  /// Get comprehensive locale date information
  ///
  /// **Returns:**
  /// Map with all locale and date information
  static Map<String, dynamic> getCompleteLocaleInfo(DateTime date) {
    final locale = LocaleManager().currentLocale;
    final localeString = LocaleManager().currentLocaleString;

    return {
      'localeString': localeString,
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
      'localeName': _getLocaleName(localeString),
      'dateFormatted': date.format(),
      'dateShort': date.format(style: DateFormatStyle.short),
      'dateMedium': date.format(style: DateFormatStyle.medium),
      'dateLong': date.format(style: DateFormatStyle.long),
      'dateFull': date.format(style: DateFormatStyle.full),
      'monthName': date.getMonthName(),
      'monthAbbr': date.getMonthName(abbreviated: true),
      'weekdayName': date.getWeekdayName(),
      'weekdayAbbr': date.getWeekdayName(abbreviated: true),
    };
  }

  // ============ METHOD 9: Custom Locale Date with Pattern ============

  /// Format date with custom pattern in current locale
  ///
  /// **Parameters:**
  /// - [date] DateTime to format
  /// - [pattern] DateFormat pattern (e.g., "dd/MM/yyyy", "EEEE, d MMMM")
  ///
  /// **Usage:**
  /// ```dart
  /// DateTime date = DateTime(2026, 1, 15);
  ///
  /// print(date.formatWithPattern('dd/MM/yyyy'));
  /// // "15/01/2026"
  ///
  /// print(date.formatWithPattern('EEEE, d MMMM'));
  /// // en_US -> "Thursday, 15 January"
  /// // ro_RO -> "joi, 15 ianuarie"
  ///
  /// print(date.formatWithPattern('d MMM yy'));
  /// // "15 Jan 26"
  /// ```
  static String getCustomFormattedDate(DateTime date, String pattern) =>
      date.formatWithPattern(pattern);

  // ============ METHOD 10: Change Locale and Get Date ============

  /// Change app locale at runtime and get formatted date
  ///
  /// **Parameters:**
  /// - [date] DateTime to format
  /// - [newLocale] Locale to temporarily use
  ///
  /// **Returns:**
  /// Formatted date in specified locale
  ///
  /// **Usage:**
  /// ```dart
  /// DateTime date = DateTime(2026, 1, 15);
  ///
  /// // Get date in English
  /// String enDate = getDateInSpecificLocale(date, const Locale('en', 'US'));
  /// print(enDate); // "Jan 15, 2026"
  ///
  /// // Get date in Romanian
  /// String roDate = getDateInSpecificLocale(date, const Locale('ro', 'RO'));
  /// print(roDate); // "ian. 15, 2026"
  ///
  /// // Get date in Russian
  /// String ruDate = getDateInSpecificLocale(date, const Locale('ru', 'RU'));
  /// print(ruDate); // "15 янв. 2026 г."
  /// ```
  static String getDateInSpecificLocale(DateTime date, Locale locale) =>
      date.formatByLocale(
        locale.toString().replaceAll('-', '_'),
      );

  /// Private: Get locale display name
  static String _getLocaleName(String localeString) {
    final localeNames = {
      'en_US': 'English (United States)',
      'en_GB': 'English (Great Britain)',
      'ro_RO': 'Romanian (Romania)',
      'ru_RU': 'Russian (Russia)',
      'de_DE': 'German (Germany)',
      'fr_FR': 'French (France)',
      'es_ES': 'Spanish (Spain)',
      'it_IT': 'Italian (Italy)',
    };
    return localeNames[localeString] ?? localeString;
  }
}
