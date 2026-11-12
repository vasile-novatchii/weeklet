import 'package:flutter/material.dart';
import 'package:weeklet/domain/entities/settings.dart';

abstract class SettingsRepository {
  Future<Settings> getSettings();
  Future<void> saveTheme(ThemeMode themeMode);
  Future<void> saveLocale(Locale? locale);
  Future<void> saveCurrency(String symbol);
  Future<void> saveBiometricEnabled({required bool enabled});
  Future<void> clearPreferences();
  Future<void> clearAll();
}
