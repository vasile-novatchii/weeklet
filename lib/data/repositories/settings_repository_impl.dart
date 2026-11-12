import 'package:flutter/material.dart';
import 'package:weeklet/data/datasources/local/settings_local_data_source.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Settings> getSettings() async {
    try {
      return await _localDataSource.getSettings();
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.getSettings] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveTheme(ThemeMode themeMode) async {
    try {
      await _localDataSource.saveTheme(themeMode);
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.saveTheme] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveLocale(Locale? locale) async {
    try {
      await _localDataSource.saveLocale(locale);
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.saveLocale] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveCurrency(String symbol) async {
    try {
      await _localDataSource.saveCurrency(symbol);
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.saveCurrency] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveBiometricEnabled({required bool enabled}) async {
    try {
      await _localDataSource.saveBiometricEnabled(enabled: enabled);
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.saveBiometricEnabled] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearPreferences() async {
    try {
      await _localDataSource.clearSettings();
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.clearPreferences] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    // clearAll() on SettingsRepository clears only the settings box.
    // The ResetAllDataUseCase is responsible for clearing all repositories.
    try {
      await _localDataSource.clearSettings();
    } catch (e) {
      debugPrint('[SettingsRepositoryImpl.clearAll] error: $e');
      rethrow;
    }
  }
}
