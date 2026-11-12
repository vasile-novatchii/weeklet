import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Singleton service to manage device locales and provide app-wide locale access
///
/// **Features:**
/// - Reads device system locale automatically
/// - Supports multiple locales with fallback to English
/// - Provides locale string for intl package formatting
/// - Thread-safe singleton implementation
///
/// **Usage:**
/// ```dart
/// // In main()
/// LocaleManager().initialize(deviceLocale);
///
/// // In widgets
/// String currentLocale = LocaleManager().currentLocaleString; // "en"
/// Locale locale = LocaleManager().currentLocale;
/// ```
class LocaleManager {
  factory LocaleManager() => _instance;

  LocaleManager._internal();
  static final LocaleManager _instance = LocaleManager._internal();

  late Locale _currentLocale;

  /// List of supported locales in the app.
  ///
  /// **Supported Languages:**
  /// - English (en) — fallback for any unsupported system locale
  /// - Romanian (ro)
  /// - Russian (ru)
  ///
  /// Country codes are intentionally omitted so that
  /// `MaterialApp.localeResolutionCallback` can match by `languageCode`
  /// alone and fall through to `Locale('en')` for any other locale.
  ///
  /// LOC-01: only en/ro/ru. Any other system locale is mapped to en by
  /// `MaterialApp.localeResolutionCallback` in [WeekletApp].
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ro'),
    Locale('ru'),
  ];

  /// Initialize LocaleManager with device locale
  void initialize(Locale? deviceLocale) {
    _currentLocale =
        _findMatchingLocale(deviceLocale) ?? const Locale('en');
    intl.Intl.defaultLocale = _currentLocale.toString().replaceAll('-', '_');
  }

  /// Get current locale as string (e.g., "en")
  ///
  /// Used for intl package formatting
  ///
  /// **Returns:**
  /// Locale string in format "language" (e.g., "en", "ro", "ru")
  ///
  /// **Example:**
  /// ```dart
  /// String locale = LocaleManager().currentLocaleString; // "en"
  /// ```
  String get currentLocaleString =>
      _currentLocale.toString().replaceAll('-', '_');

  /// Get current locale as Locale object
  ///
  /// **Returns:**
  /// Locale object with language code (e.g., `Locale('en')`, `Locale('ro')`)
  ///
  /// **Example:**
  /// ```dart
  /// Locale locale = LocaleManager().currentLocale; // Locale('en')
  /// ```
  Locale get currentLocale => _currentLocale;

  /// Set app locale at runtime
  ///
  /// **Parameters:**
  /// - [locale] New Locale to set
  ///
  /// **Note:**
  /// After calling this, you need to trigger a rebuild:
  /// ```dart
  /// LocaleManager().setLocale(const Locale('ro'));
  /// (context as Element).markNeedsBuild();
  /// ```
  ///
  /// **Example:**
  /// ```dart
  /// LocaleManager().setLocale(const Locale('ro'));
  /// ```
  void setLocale(Locale locale) {
    final matched = _findMatchingLocale(locale) ?? const Locale('en');
    _currentLocale = matched;
    intl.Intl.defaultLocale = matched.toString().replaceAll('-', '_');
  }

  /// Find matching locale from supported locales
  ///
  /// **Priority:**
  /// 1. Exact match (language + country code) - e.g., en_US matches en_US
  /// 2. Language-only match (language code only) - e.g., en matches en_GB
  /// 3. Return null if no match found
  ///
  /// **Parameters:**
  /// - [locale] Device locale to match
  ///
  /// **Returns:**
  /// Matched Locale from supportedLocales or null if no match
  ///
  /// **Example:**
  /// ```dart
  /// // Device: ro_RO -> Returns: Locale('ro') (language match)
  /// // Device: ro_MD -> Returns: Locale('ro') (language match)
  /// // Device: ja_JP -> Returns: null (no match)
  /// ```
  Locale? _findMatchingLocale(Locale? locale) {
    if (locale == null) return null;

    // Try exact match: language + country
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode) {
        return supported;
      }
    }

    // Try language-only match
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }

    // No match found
    return null;
  }
}
