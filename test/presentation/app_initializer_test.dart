import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/app_initializer.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_event.dart';
import 'package:weeklet/presentation/blocs/stats/stats_state.dart';

SettingsLoaded _loaded(Locale? locale) => SettingsLoaded(
  settings: Settings(
    themeMode: ThemeMode.system,
    locale: locale,
    currencySymbol: r'$',
    biometricEnabled: false,
  ),
);

class _MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class _MockExpenseBloc extends MockBloc<ExpenseEvent, ExpenseState>
    implements ExpenseBloc {}

class _MockIncomeBloc extends MockBloc<IncomeEvent, IncomeState>
    implements IncomeBloc {}

class _MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

void main() {
  late _MockCategoryBloc categoryBloc;
  late _MockExpenseBloc expenseBloc;
  late _MockIncomeBloc incomeBloc;
  late _MockSettingsBloc settingsBloc;
  late _MockStatsBloc statsBloc;

  setUpAll(() {
    registerFallbackValue(const GetAllCategoriesEvent());
    registerFallbackValue(const LoadExpensesRequested());
    registerFallbackValue(const LoadIncomesRequested());
    registerFallbackValue(const LoadSettingsRequested());
    registerFallbackValue(const LoadMonthlyStats(year: 2026));
  });

  setUp(() {
    categoryBloc = _MockCategoryBloc();
    expenseBloc = _MockExpenseBloc();
    incomeBloc = _MockIncomeBloc();
    settingsBloc = _MockSettingsBloc();
    statsBloc = _MockStatsBloc();
    when(() => categoryBloc.state).thenReturn(const CategoryLoading());
    when(() => expenseBloc.state).thenReturn(const ExpenseInitial());
    when(() => incomeBloc.state).thenReturn(const IncomeInitial());
    when(() => settingsBloc.state).thenReturn(_loaded(null));
    when(() => statsBloc.state).thenReturn(const StatsInitial());
    GetIt.instance.registerSingleton<SettingsBloc>(settingsBloc);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Future<void> pump(WidgetTester tester, Locale locale, int tick) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CategoryBloc>.value(value: categoryBloc),
          BlocProvider<ExpenseBloc>.value(value: expenseBloc),
          BlocProvider<IncomeBloc>.value(value: incomeBloc),
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<StatsBloc>.value(value: statsBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: AppInitializer(child: Text('tick $tick')),
        ),
      ),
    );
  }

  testWidgets(
    'dispatches EnsureDefaultCategoryRequested once with the locale name',
    (tester) async {
      await pump(tester, const Locale('ro'), 1);
      await tester.pump();

      final captured = verify(() => categoryBloc.add(captureAny())).captured;
      final ensure = captured.whereType<EnsureDefaultCategoryRequested>();
      expect(ensure, hasLength(1));
      expect(ensure.single.localizedName, 'Zilnic');

      // Rebuild with different child: must not dispatch again.
      await pump(tester, const Locale('ro'), 2);
      await tester.pump();
      verifyNever(() => categoryBloc.add(any()));
    },
  );

  testWidgets(
    'uses the saved in-app language, not the device locale',
    (tester) async {
      when(() => settingsBloc.state).thenReturn(_loaded(const Locale('ru')));
      await pump(tester, const Locale('ro'), 1);
      await tester.pump();

      final ensure = verify(
        () => categoryBloc.add(captureAny()),
      ).captured.whereType<EnsureDefaultCategoryRequested>();
      expect(ensure, hasLength(1));
      expect(
        ensure.single.localizedName,
        lookupAppLocalizations(
          const Locale('ru'),
        ).defaultCategoryName,
      );
    },
  );

  testWidgets(
    'waits for settings to load before seeding',
    (tester) async {
      final controller = StreamController<SettingsState>.broadcast();
      addTearDown(controller.close);
      when(() => settingsBloc.state).thenReturn(const SettingsLoading());
      when(() => settingsBloc.stream).thenAnswer((_) => controller.stream);

      await pump(tester, const Locale('ro'), 1);
      await tester.pump();
      verifyNever(() => categoryBloc.add(any()));

      controller.add(_loaded(const Locale('ru')));
      await tester.pump();
      await tester.pump();

      final ensure = verify(
        () => categoryBloc.add(captureAny()),
      ).captured.whereType<EnsureDefaultCategoryRequested>();
      expect(ensure, hasLength(1));
      expect(
        ensure.single.localizedName,
        lookupAppLocalizations(const Locale('ru')).defaultCategoryName,
      );
    },
  );
}
