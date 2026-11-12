import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:weeklet/domain/entities/settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.settings,
    this.actionError,
  });

  final Settings settings;
  final String? actionError;

  // Convenience getters for MaterialApp wiring and widget consumption
  ThemeMode get themeMode => settings.themeMode;
  Locale? get locale => settings.locale;
  String get currencySymbol => settings.currencySymbol;
  bool get biometricEnabled => settings.biometricEnabled;

  SettingsLoaded copyWith({
    Settings? settings,
    String? actionError,
  }) =>
      SettingsLoaded(
        settings: settings ?? this.settings,
        actionError:
            actionError, // allow null to reset actionError (DO NOT use ?? this.actionError)
      );

  @override
  List<Object?> get props => [settings, actionError];
}

final class SettingsFailure extends SettingsState {
  const SettingsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
