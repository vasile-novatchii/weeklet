import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/core/di/service_locator.dart' show sl;
import 'package:weeklet/core/services/biometric_service.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/settings/clear_preferences_usecase.dart';
import 'package:weeklet/domain/usecases/settings/get_settings_usecase.dart';
import 'package:weeklet/domain/usecases/settings/reset_all_data_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_biometric_enabled_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_currency_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_locale_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_theme_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required this.getSettingsUseCase,
    required this.saveThemeUseCase,
    required this.saveLocaleUseCase,
    required this.saveCurrencyUseCase,
    required this.saveBiometricEnabledUseCase,
    required this.clearPreferencesUseCase,
    required this.resetAllDataUseCase,
    required this.biometricService,
  }) : super(const SettingsInitial()) {
    on<LoadSettingsRequested>(_onLoadSettings);
    on<ThemeChanged>(_onThemeChanged);
    on<LocaleChanged>(_onLocaleChanged);
    on<CurrencyChanged>(_onCurrencyChanged);
    on<BiometricToggled>(_onBiometricToggled);
    on<ClearPreferencesRequested>(_onClearPreferences);
    on<ResetAllDataRequested>(_onResetAllData);
  }

  final GetSettingsUseCase getSettingsUseCase;
  final SaveThemeUseCase saveThemeUseCase;
  final SaveLocaleUseCase saveLocaleUseCase;
  final SaveCurrencyUseCase saveCurrencyUseCase;
  final SaveBiometricEnabledUseCase saveBiometricEnabledUseCase;
  final ClearPreferencesUseCase clearPreferencesUseCase;
  final ResetAllDataUseCase resetAllDataUseCase;
  final BiometricService biometricService;

  Future<void> _onLoadSettings(
    LoadSettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await getSettingsUseCase(NoParams());
      // Sync LocaleManager with persisted locale
      if (settings.locale != null) {
        LocaleManager().setLocale(settings.locale!);
      }
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      debugPrint('error in _onLoadSettings: $e');
      emit(const SettingsFailure('settingsLoadError'));
    }
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state case final SettingsLoaded st) {
      try {
        await saveThemeUseCase(event.themeMode);
        emit(st.copyWith(
          settings: st.settings.copyWith(themeMode: event.themeMode),
          actionError: null,
        ));
      } catch (e) {
        debugPrint('error in _onThemeChanged: $e');
        emit(st.copyWith(actionError: e.toString()));
      }
    }
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state case final SettingsLoaded st) {
      try {
        await saveLocaleUseCase(event.locale);
        // Sync LocaleManager — must call setLocale for intl formatting to update
        if (event.locale != null) {
          LocaleManager().setLocale(event.locale!);
        } else {
          // System default: reset to device locale
          final deviceLocale = PlatformDispatcher.instance.locale;
          LocaleManager().initialize(deviceLocale);
        }
        emit(st.copyWith(
          settings: st.settings.copyWith(locale: event.locale),
          actionError: null,
        ));
      } catch (e) {
        debugPrint('error in _onLocaleChanged: $e');
        emit(st.copyWith(actionError: e.toString()));
      }
    }
  }

  Future<void> _onCurrencyChanged(
    CurrencyChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state case final SettingsLoaded st) {
      try {
        await saveCurrencyUseCase(event.symbol);
        emit(st.copyWith(
          settings: st.settings.copyWith(currencySymbol: event.symbol),
          actionError: null,
        ));
      } catch (e) {
        debugPrint('error in _onCurrencyChanged: $e');
        emit(st.copyWith(actionError: e.toString()));
      }
    }
  }

  Future<void> _onBiometricToggled(
    BiometricToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (state case final SettingsLoaded st) {
      if (!event.enabled) {
        // Disabling biometrics — no auth needed, just save
        try {
          await saveBiometricEnabledUseCase(
            const SaveBiometricEnabledParams(enabled: false),
          );
          emit(st.copyWith(
            settings: st.settings.copyWith(biometricEnabled: false),
            actionError: null,
          ));
        } catch (e) {
          debugPrint('error in _onBiometricToggled (disable): $e');
          emit(st.copyWith(actionError: e.toString()));
        }
        return;
      }

      // Enabling: perform test auth scan first.
      // reason is supplied by the calling widget via AppLocalizations;
      // fall back to sentinel string if not provided (BLoC must not import
      // AppLocalizations — Pitfall 3 preserved).
      final reason = event.reason.isNotEmpty
          ? event.reason
          : 'biometricVerifyReason';
      final authenticated = await biometricService.authenticate(
        reason: reason,
      );

      if (!authenticated) {
        // Revert — scan failed or was cancelled (per D-08)
        emit(st.copyWith(
          settings: st.settings.copyWith(biometricEnabled: false),
          actionError: 'errorBiometricFailed',
        ));
        return;
      }

      try {
        await saveBiometricEnabledUseCase(
          const SaveBiometricEnabledParams(enabled: true),
        );
        emit(st.copyWith(
          settings: st.settings.copyWith(biometricEnabled: true),
          actionError: null,
        ));
      } catch (e) {
        debugPrint('error in _onBiometricToggled (enable, save): $e');
        emit(st.copyWith(
          settings: st.settings.copyWith(biometricEnabled: false),
          actionError: e.toString(),
        ));
      }
    }
  }

  Future<void> _onClearPreferences(
    ClearPreferencesRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state case final SettingsLoaded st) {
      try {
        await clearPreferencesUseCase(NoParams());
        // Reload settings to reflect defaults
        add(const LoadSettingsRequested());
      } catch (e) {
        debugPrint('error in _onClearPreferences: $e');
        emit(st.copyWith(actionError: e.toString()));
      }
    }
  }

  Future<void> _onResetAllData(
    ResetAllDataRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state case final SettingsLoaded st) {
      try {
        await resetAllDataUseCase(NoParams());
        // Sync all data BLoCs so screens update immediately without restart
        sl<ExpenseBloc>().add(const LoadExpensesRequested());
        sl<IncomeBloc>().add(const LoadIncomesRequested());
        sl<CategoryBloc>().add(const GetAllCategoriesEvent());
        sl<StatsBloc>().add(LoadMonthlyStats(year: DateTime.now().year));
        add(const LoadSettingsRequested());
      } catch (e) {
        debugPrint('error in _onResetAllData: $e');
        emit(st.copyWith(actionError: e.toString()));
      }
    }
  }
}
