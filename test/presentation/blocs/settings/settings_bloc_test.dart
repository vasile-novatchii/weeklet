import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weeklet/core/services/biometric_service.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/settings/clear_preferences_usecase.dart';
import 'package:weeklet/domain/usecases/settings/get_settings_usecase.dart';
import 'package:weeklet/domain/usecases/settings/reset_all_data_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_biometric_enabled_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_currency_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_locale_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_theme_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import '../../../helpers/fake_blocs.dart';

// ---------------------------------------------------------------------------
// File-private stub use cases
// ---------------------------------------------------------------------------

class _StubGetSettingsUseCase implements GetSettingsUseCase {
  Settings returnValue = Settings.defaults();
  bool shouldThrow = false;

  @override
  Future<Settings> call(NoParams params) async {
    if (shouldThrow) throw Exception('settings load error');
    return returnValue;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubSaveThemeUseCase implements SaveThemeUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(ThemeMode params) async {
    if (shouldThrow) throw Exception('save theme error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubSaveLocaleUseCase implements SaveLocaleUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(Locale? params) async {
    if (shouldThrow) throw Exception('save locale error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubSaveCurrencyUseCase implements SaveCurrencyUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(String params) async {
    if (shouldThrow) throw Exception('save currency error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubSaveBiometricEnabledUseCase
    implements SaveBiometricEnabledUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(SaveBiometricEnabledParams params) async {
    if (shouldThrow) throw Exception('save biometric error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubClearPreferencesUseCase implements ClearPreferencesUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(NoParams params) async {
    if (shouldThrow) throw Exception('clear preferences error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubResetAllDataUseCase implements ResetAllDataUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(NoParams params) async {
    if (shouldThrow) throw Exception('reset all data error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// File-private BiometricService stub
// ---------------------------------------------------------------------------

class _StubBiometricService implements BiometricService {
  bool authenticateResult = true;

  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<bool> authenticate({required String reason}) async =>
      authenticateResult;
}

// ---------------------------------------------------------------------------
// Shared stub references (reset in each group's setUp)
// ---------------------------------------------------------------------------

late _StubGetSettingsUseCase _stubGet;
late _StubSaveThemeUseCase _stubTheme;
late _StubSaveLocaleUseCase _stubLocale;
late _StubSaveCurrencyUseCase _stubCurrency;
late _StubSaveBiometricEnabledUseCase _stubBiometric;
late _StubClearPreferencesUseCase _stubClear;
late _StubResetAllDataUseCase _stubReset;
late _StubBiometricService _stubAuth;

// ---------------------------------------------------------------------------
// Bloc factory + seed helper
// ---------------------------------------------------------------------------

SettingsBloc _makeBloc() => SettingsBloc(
      getSettingsUseCase: _stubGet,
      saveThemeUseCase: _stubTheme,
      saveLocaleUseCase: _stubLocale,
      saveCurrencyUseCase: _stubCurrency,
      saveBiometricEnabledUseCase: _stubBiometric,
      clearPreferencesUseCase: _stubClear,
      resetAllDataUseCase: _stubReset,
      biometricService: _stubAuth,
    );

SettingsLoaded _loadedSeed() => const SettingsLoaded(
      settings: Settings(
        themeMode: ThemeMode.system,
        locale: null,
        currencySymbol: 'MDL',
        biometricEnabled: false,
      ),
    );

void _resetStubs() {
  _stubGet = _StubGetSettingsUseCase();
  _stubTheme = _StubSaveThemeUseCase();
  _stubLocale = _StubSaveLocaleUseCase();
  _stubCurrency = _StubSaveCurrencyUseCase();
  _stubBiometric = _StubSaveBiometricEnabledUseCase();
  _stubClear = _StubClearPreferencesUseCase();
  _stubReset = _StubResetAllDataUseCase();
  _stubAuth = _StubBiometricService();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Required for LocaleChanged(null) path: PlatformDispatcher.instance.locale
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsBloc — initial state', () {
    setUp(_resetStubs);

    test('initial state is SettingsInitial', () {
      final bloc = _makeBloc();
      addTearDown(bloc.close);
      expect(bloc.state, const SettingsInitial());
    });
  });

  group('SettingsBloc — load', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'LoadSettingsRequested emits SettingsLoading then SettingsLoaded',
      build: _makeBloc,
      act: (bloc) => bloc.add(const LoadSettingsRequested()),
      expect: () => [const SettingsLoading(), isA<SettingsLoaded>()],
    );

    blocTest<SettingsBloc, SettingsState>(
      'LoadSettingsRequested emits SettingsLoading then SettingsFailure on throw',
      setUp: () => _stubGet.shouldThrow = true,
      build: _makeBloc,
      act: (bloc) => bloc.add(const LoadSettingsRequested()),
      expect: () => [const SettingsLoading(), isA<SettingsFailure>()],
    );
  });

  group('SettingsBloc — theme', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'ThemeChanged updates themeMode',
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const ThemeChanged(ThemeMode.dark)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.themeMode,
          'themeMode',
          ThemeMode.dark,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'ThemeChanged silently ignored when not in SettingsLoaded',
      build: _makeBloc,
      act: (bloc) => bloc.add(const ThemeChanged(ThemeMode.dark)),
      expect: () => <SettingsState>[],
    );
  });

  group('SettingsBloc — locale', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'LocaleChanged with explicit locale updates settings.locale',
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const LocaleChanged(Locale('ro'))),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.locale,
          'locale',
          const Locale('ro'),
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'LocaleChanged with null sets locale to null',
      build: _makeBloc,
      seed: () => const SettingsLoaded(
        settings: Settings(
          themeMode: ThemeMode.system,
          locale: Locale('ro'),
          currencySymbol: 'MDL',
          biometricEnabled: false,
        ),
      ),
      act: (bloc) => bloc.add(const LocaleChanged(null)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.locale,
          'locale',
          isNull,
        ),
      ],
    );
  });

  group('SettingsBloc — currency', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'CurrencyChanged updates currencySymbol',
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const CurrencyChanged('EUR')),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.currencySymbol,
          'currencySymbol',
          'EUR',
        ),
      ],
    );
  });

  group('SettingsBloc — biometric disable', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'BiometricToggled(enabled: false) saves false without calling authenticate',
      build: _makeBloc,
      seed: () => const SettingsLoaded(
        settings: Settings(
          themeMode: ThemeMode.system,
          locale: null,
          currencySymbol: 'MDL',
          biometricEnabled: true,
        ),
      ),
      act: (bloc) => bloc.add(const BiometricToggled(enabled: false)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.biometricEnabled,
          'biometricEnabled',
          false,
        ),
      ],
    );
  });

  group('SettingsBloc — biometric enable', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'BiometricToggled(enabled: true) when auth succeeds saves true',
      setUp: () => _stubAuth.authenticateResult = true,
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const BiometricToggled(enabled: true)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.biometricEnabled,
          'biometricEnabled',
          true,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'BiometricToggled(enabled: true) when auth fails sets errorBiometricFailed',
      setUp: () => _stubAuth.authenticateResult = false,
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const BiometricToggled(enabled: true)),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.actionError,
          'actionError',
          'errorBiometricFailed',
        ),
      ],
    );
  });

  group('SettingsBloc — clear preferences', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'ClearPreferencesRequested triggers reload',
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const ClearPreferencesRequested()),
      expect: () => [const SettingsLoading(), isA<SettingsLoaded>()],
    );
  });

  group('SettingsBloc — reset all data', () {
    setUp(_resetStubs);

    blocTest<SettingsBloc, SettingsState>(
      'ResetAllDataRequested calls all 4 fake BLoCs and triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<ExpenseBloc>(FakeExpenseBloc());
        GetIt.instance.registerSingleton<IncomeBloc>(FakeIncomeBloc());
        GetIt.instance.registerSingleton<CategoryBloc>(FakeCategoryBloc());
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const ResetAllDataRequested()),
      expect: () => [const SettingsLoading(), isA<SettingsLoaded>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<SettingsBloc, SettingsState>(
      'ResetAllDataRequested use case error sets actionError',
      setUp: () {
        _stubReset.shouldThrow = true;
        GetIt.instance.registerSingleton<ExpenseBloc>(FakeExpenseBloc());
        GetIt.instance.registerSingleton<IncomeBloc>(FakeIncomeBloc());
        GetIt.instance.registerSingleton<CategoryBloc>(FakeCategoryBloc());
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _loadedSeed,
      act: (bloc) => bloc.add(const ResetAllDataRequested()),
      expect: () => [
        isA<SettingsLoaded>().having(
          (s) => s.actionError,
          'actionError',
          isNotNull,
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );
  });
}
