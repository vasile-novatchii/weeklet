import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Settings extends Equatable {
  const Settings({
    required this.themeMode,
    required this.locale,
    required this.currencySymbol,
    required this.biometricEnabled,
  });

  factory Settings.defaults() => const Settings(
        themeMode: ThemeMode.system,
        locale: null,
        currencySymbol: 'MDL',
        biometricEnabled: false,
      );

  final ThemeMode themeMode;
  final Locale? locale; // null = system default
  final String currencySymbol;
  final bool biometricEnabled;

  Settings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? currencySymbol,
    bool? biometricEnabled,
  }) =>
      Settings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale, // allow null to reset to system (DO NOT use locale ?? this.locale)
        currencySymbol: currencySymbol ?? this.currencySymbol,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      );

  @override
  List<Object?> get props => [
        themeMode,
        locale,
        currencySymbol,
        biometricEnabled,
      ];
}
