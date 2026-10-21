import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/settings/settings_screen.dart';
import '../../../helpers/test_app.dart';

// ---------------------------------------------------------------------------
// Mock declarations
// MockBloc<E, S> from bloc_test does not extend the concrete BLoC subclass.
// Using `implements SettingsBloc` allows BlocProvider<SettingsBloc>.value().
// ---------------------------------------------------------------------------

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUpAll(() {
    // Concrete subclasses used as fallback values — sealed classes cannot be
    // implemented with Fake outside their defining library.
    registerFallbackValue(const LoadSettingsRequested());
    registerFallbackValue(const SettingsInitial());

    // PackageInfo stub — prevents MissingPluginException when
    // SettingsScreen's initState calls PackageInfo.fromPlatform().
    PackageInfo.setMockInitialValues(
      appName: 'Weeklet',
      packageName: 'com.weeklet.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();

    when(() => mockSettingsBloc.state)
        .thenReturn(SettingsLoaded(settings: Settings.defaults()));
    whenListen(
      mockSettingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: SettingsLoaded(settings: Settings.defaults()),
    );

    GetIt.instance.registerSingleton<SettingsBloc>(mockSettingsBloc);
  });

  tearDown(() async => GetIt.instance.reset());

  Future<void> pumpSettingsScreen(WidgetTester tester) => pumpApp(
    tester,
    const SettingsScreen(),
    providers: [
      BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
    ],
  );

  group('SettingsScreen', () {
    testWidgets(
      'shows CircularProgressIndicator when state is SettingsInitial',
      (tester) async {
        when(() => mockSettingsBloc.state).thenReturn(const SettingsInitial());
        whenListen(
          mockSettingsBloc,
          const Stream<SettingsState>.empty(),
          initialState: const SettingsInitial(),
        );

        await pumpSettingsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows CircularProgressIndicator when state is SettingsLoading',
      (tester) async {
        when(() => mockSettingsBloc.state)
            .thenReturn(const SettingsLoading());
        whenListen(
          mockSettingsBloc,
          const Stream<SettingsState>.empty(),
          initialState: const SettingsLoading(),
        );

        await pumpSettingsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'renders settings list when SettingsLoaded',
      (tester) async {
        await pumpSettingsScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(ListView), findsOneWidget);
        // Biometric switch is visible in the Security section
        expect(find.byType(Switch), findsOneWidget);
      },
    );

    testWidgets(
      'dispatches BiometricToggled when biometric switch is tapped',
      (tester) async {
        await pumpSettingsScreen(tester);
        await tester.pump();

        await tester.tap(find.byType(Switch).first);
        await tester.pump();

        verify(
          () => mockSettingsBloc.add(any(that: isA<BiometricToggled>())),
        ).called(1);
      },
    );

    testWidgets(
      'dispatches ThemeChanged when a theme option is selected in the sheet',
      (tester) async {
        await pumpSettingsScreen(tester);
        await tester.pump();

        // Open ThemeSelectionSheet via the Theme tile.
        await tester.tap(find.byIcon(Icons.palette_outlined));
        await tester.pumpAndSettle();

        // Tap 'Dark' — different from the default ThemeMode.system.
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();

        verify(
          () => mockSettingsBloc.add(any(that: isA<ThemeChanged>())),
        ).called(1);
      },
    );

    testWidgets(
      'dispatches LocaleChanged when a language option is selected in the sheet',
      (tester) async {
        await pumpSettingsScreen(tester);
        await tester.pump();

        // Open LanguageSelectionSheet via the Language tile.
        await tester.tap(find.byIcon(Icons.language));
        await tester.pumpAndSettle();

        // Tap 'English' — different from the default null (system locale).
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        verify(
          () => mockSettingsBloc.add(any(that: isA<LocaleChanged>())),
        ).called(1);
      },
    );

    testWidgets(
      'dispatches CurrencyChanged when a currency option is selected in the sheet',
      (tester) async {
        await pumpSettingsScreen(tester);
        await tester.pump();

        // Open CurrencySelectionSheet via the Currency tile.
        await tester.tap(find.byIcon(Icons.attach_money));
        await tester.pumpAndSettle();

        // Tap 'EUR' — different from the default 'MDL'.
        await tester.tap(find.text('EUR'));
        await tester.pumpAndSettle();

        verify(
          () => mockSettingsBloc.add(any(that: isA<CurrencyChanged>())),
        ).called(1);
      },
    );

    testWidgets(
      'version tile shows version subtitle and a chevron',
      (tester) async {
        await pumpSettingsScreen(tester);
        await tester.pump();
        await tester.pump();

        await tester.scrollUntilVisible(
          find.byIcon(Icons.info_outline),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        final tile = find.ancestor(
          of: find.byIcon(Icons.info_outline),
          matching: find.byType(ListTile),
        );

        expect(
          find.descendant(of: tile, matching: find.text('1.0.0')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: tile,
            matching: find.byIcon(Icons.chevron_right),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping version tile opens LicensePage', (tester) async {
      await pumpSettingsScreen(tester);
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.byIcon(Icons.info_outline),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(LicensePage), findsOneWidget);
    });
  });
}
