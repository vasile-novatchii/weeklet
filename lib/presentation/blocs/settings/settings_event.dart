import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial settings load from Hive on app startup.
final class LoadSettingsRequested extends SettingsEvent {
  const LoadSettingsRequested();
}

/// User changed the theme mode.
final class ThemeChanged extends SettingsEvent {
  const ThemeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

/// User changed the display language. null = system default.
final class LocaleChanged extends SettingsEvent {
  const LocaleChanged(this.locale);

  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}

/// User changed the currency symbol (e.g., 'MDL', 'EUR').
final class CurrencyChanged extends SettingsEvent {
  const CurrencyChanged(this.symbol);

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

/// User toggled the biometric authentication switch.
final class BiometricToggled extends SettingsEvent {
  const BiometricToggled({required this.enabled, this.reason = ''});

  final bool enabled;

  /// Localized reason string shown in the native biometric auth dialog.
  /// Supplied by the calling widget via AppLocalizations; empty string
  /// falls back to a sentinel in the BLoC handler.
  final String reason;

  @override
  List<Object?> get props => [enabled, reason];
}

/// User confirmed clearing preferences (settings box reset to defaults).
final class ClearPreferencesRequested extends SettingsEvent {
  const ClearPreferencesRequested();
}

/// User confirmed resetting all app data (all 4 Hive boxes cleared).
final class ResetAllDataRequested extends SettingsEvent {
  const ResetAllDataRequested();
}
