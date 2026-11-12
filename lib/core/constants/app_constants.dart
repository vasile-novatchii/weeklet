/// Application-wide constants.
///
/// Phase 4 (Settings) will replace [DEFAULT_CURRENCY] with a user-configurable
/// value from [SettingsRepository]. This constant becomes the fallback/default
/// at that point.
class AppConstants {
  AppConstants._();

  /// Default currency symbol displayed throughout the app.
  ///
  /// Replaces scattered hardcoded 'MDL', 'lei', 'RON' literals.
  static const String DEFAULT_CURRENCY = 'MDL';
}
