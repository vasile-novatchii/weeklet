import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weeklet/core/constants/app_constants.dart';
import 'package:weeklet/domain/entities/settings.dart';

abstract class SettingsLocalDataSource {
  Future<Settings> getSettings();
  Future<void> saveTheme(ThemeMode mode);
  Future<void> saveLocale(Locale? locale);
  Future<void> saveCurrency(String symbol);
  Future<void> saveBiometricEnabled({required bool enabled});
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale_language';
  static const String _currencyKey = 'currency_symbol';
  static const String _biometricKey = 'biometric_enabled';

  @override
  Future<Settings> getSettings() async {
    try {
      final themeIndex = _box.get(
        _themeKey,
        defaultValue: ThemeMode.system.index,
      ) as int;
      final localeCode = _box.get(_localeKey) as String?;
      final currencySymbol = _box.get(
        _currencyKey,
        defaultValue: AppConstants.DEFAULT_CURRENCY,
      ) as String;
      final biometricEnabled = _box.get(
        _biometricKey,
        defaultValue: false,
      ) as bool;

      final themeMode = themeIndex >= 0 && themeIndex < ThemeMode.values.length
          ? ThemeMode.values[themeIndex]
          : ThemeMode.system;
      return Settings(
        themeMode: themeMode,
        locale: localeCode != null ? _localeFromCode(localeCode) : null,
        currencySymbol: currencySymbol,
        biometricEnabled: biometricEnabled,
      );
    } catch (e) {
      debugPrint('[SettingsLocalDataSourceImpl.getSettings] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveTheme(ThemeMode mode) async {
    try {
      await _box.put(_themeKey, mode.index);
    } catch (e) {
      debugPrint('[SettingsLocalDataSourceImpl.saveTheme] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveLocale(Locale? locale) async {
    try {
      if (locale == null) {
        await _box.delete(_localeKey);
      } else {
        await _box.put(_localeKey, locale.languageCode);
      }
    } catch (e) {
      debugPrint('[SettingsLocalDataSourceImpl.saveLocale] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveCurrency(String symbol) async {
    try {
      await _box.put(_currencyKey, symbol);
    } catch (e) {
      debugPrint('[SettingsLocalDataSourceImpl.saveCurrency] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveBiometricEnabled({required bool enabled}) async {
    try {
      await _box.put(_biometricKey, enabled);
    } catch (e) {
      debugPrint(
        '[SettingsLocalDataSourceImpl.saveBiometricEnabled] error: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      await _box.clear();
    } catch (e) {
      debugPrint('[SettingsLocalDataSourceImpl.clearSettings] error: $e');
      rethrow;
    }
  }

  Locale _localeFromCode(String code) {
    switch (code) {
      case 'ro':
        return const Locale('ro', 'RO');
      case 'ru':
        return const Locale('ru', 'RU');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }
}
