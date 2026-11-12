import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations,
        GlobalCupertinoLocalizations;
import 'package:weeklet/core/di/service_locator.dart' show sl;
import 'package:weeklet/core/theme/theme.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/app_initializer.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';

import 'core/router/app_routes.dart';
import 'core/utils/scroll_behavior.dart';

class WeekletApp extends StatelessWidget {
  const WeekletApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<SettingsBloc>.value(value: sl<SettingsBloc>()),
      BlocProvider<CategoryBloc>.value(value: sl<CategoryBloc>()),
      BlocProvider<ExpenseBloc>.value(value: sl<ExpenseBloc>()),
      BlocProvider<IncomeBloc>.value(value: sl<IncomeBloc>()),
      BlocProvider<StatsBloc>.value(value: sl<StatsBloc>()),
      BlocProvider<ExportBloc>.value(value: sl<ExportBloc>()),
    ],
    child: BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (prev, curr) {
        // Only rebuild MaterialApp when theme or locale changes.
        // Currency and biometric changes must NOT trigger MaterialApp rebuild.
        if (prev is SettingsLoaded && curr is SettingsLoaded) {
          return prev.themeMode != curr.themeMode ||
              prev.locale != curr.locale;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, settingsState) {
        final themeMode = settingsState is SettingsLoaded
            ? settingsState.themeMode
            : ThemeMode.system;
        final locale = settingsState is SettingsLoaded
            ? settingsState.locale
            : LocaleManager().currentLocale;

        return MaterialApp(
          title: 'Weeklet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.home,
          builder: (context, child) => AppInitializer(
            child: ScrollConfiguration(
              behavior: WeekletScrollBehavior(),
              child: child!,
            ),
          ),
          locale: locale,
          supportedLocales: LocaleManager.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // LOC-01 fallback: any unsupported device locale renders English.
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },
        );
      },
    ),
  );
}
