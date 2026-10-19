import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/presentation/screens/income/income_screen.dart';
import 'package:weeklet/presentation/screens/income/widgets/income_filter_bar.dart';
import 'package:weeklet/presentation/screens/income/widgets/income_total_card.dart';
import 'package:weeklet/presentation/screens/income/widgets/list/income_list_view.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/test_data.dart';

// MockBloc subclasses must implement the concrete BLoC type so they can be
// supplied to BlocProvider<ConcreteBloc>.value(). MockBloc's dynamic dispatch
// handles any unimplemented IncomeBloc-specific members at runtime.
class MockIncomeBloc extends MockBloc<IncomeEvent, IncomeState>
    implements IncomeBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockExportBloc extends MockBloc<ExportEvent, ExportState>
    implements ExportBloc {}

void main() {
  late MockIncomeBloc mockIncomeBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockExportBloc mockExportBloc;

  setUpAll(() {
    // LocaleManager is a singleton that requires initialization before any
    // widget that uses DateTimeExtension.getWeekdayName can be rendered.
    LocaleManager().initialize(const Locale('en'));
  });

  setUp(() {
    mockIncomeBloc = MockIncomeBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockExportBloc = MockExportBloc();

    when(() => mockIncomeBloc.state).thenReturn(const IncomeLoading());
    whenListen(
      mockIncomeBloc,
      const Stream<IncomeState>.empty(),
      initialState: const IncomeLoading(),
    );

    when(
      () => mockSettingsBloc.state,
    ).thenReturn(SettingsLoaded(settings: Settings.defaults()));
    whenListen(
      mockSettingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: SettingsLoaded(settings: Settings.defaults()),
    );

    when(() => mockExportBloc.state).thenReturn(const ExportInitial());
    whenListen(
      mockExportBloc,
      const Stream<ExportState>.empty(),
      initialState: const ExportInitial(),
    );

    // IncomeScreen has no sl<> calls in initState — GetIt registration is
    // omitted. All BLoC dependencies are provided via BlocProvider.value.
    // Note: GetIt.instance.reset() in tearDown is still safe (no-op when empty).
  });

  tearDown(() async => GetIt.instance.reset());

  Future<void> pumpIncomeScreen(WidgetTester tester) => pumpApp(
    tester,
    const IncomeScreen(),
    providers: [
      BlocProvider<IncomeBloc>.value(value: mockIncomeBloc),
      BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      BlocProvider<ExportBloc>.value(value: mockExportBloc),
    ],
  );

  group('IncomeScreen', () {
    testWidgets(
      'shows CircularProgressIndicator when state is IncomeLoading',
      (tester) async {
        await pumpIncomeScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows income list when filteredIncomes is non-empty',
      (tester) async {
        final successState = fakeIncomeSuccess(incomes: [fakeIncome()]);
        when(() => mockIncomeBloc.state).thenReturn(successState);
        whenListen(
          mockIncomeBloc,
          Stream.value(successState),
          initialState: successState,
        );

        await pumpIncomeScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(IncomeListView), findsOneWidget);
      },
    );

    testWidgets(
      'shows EmptyStateView when filteredIncomes is empty (IncomeSuccess)',
      (tester) async {
        final successState = fakeIncomeSuccess(incomes: []);
        when(() => mockIncomeBloc.state).thenReturn(successState);
        whenListen(
          mockIncomeBloc,
          Stream.value(successState),
          initialState: successState,
        );

        await pumpIncomeScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(EmptyStateView), findsOneWidget);
      },
    );

    testWidgets(
      'dispatches LoadIncomesRequested when retry button is tapped'
      ' (IncomeFailure)',
      (tester) async {
        const failureState = IncomeFailure('loadError');
        when(() => mockIncomeBloc.state).thenReturn(failureState);
        whenListen(
          mockIncomeBloc,
          Stream.value(failureState),
          initialState: failureState,
        );

        await pumpIncomeScreen(tester);
        await tester.pump();

        // The retry TextButton is rendered in the IncomeFailure branch.
        final retryButton = find.byType(TextButton);
        expect(retryButton, findsOneWidget);
        await tester.tap(retryButton);
        await tester.pump();

        verify(
          () => mockIncomeBloc.add(const LoadIncomesRequested()),
        ).called(1);
      },
    );
  });

  group('IncomeScreen empty state', () {
    void seedState(IncomeState state) {
      when(() => mockIncomeBloc.state).thenReturn(state);
      whenListen(
        mockIncomeBloc,
        Stream.value(state),
        initialState: state,
      );
    }

    testWidgets('no income at all hides filter bar and total card', (
      tester,
    ) async {
      seedState(fakeIncomeSuccess(incomes: []));
      await pumpIncomeScreen(tester);
      await tester.pump();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.byType(IncomeFilterBar), findsNothing);
      expect(find.byType(IncomeTotalCard), findsNothing);
      expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
    });

    testWidgets('empty period with other data keeps filter bar only', (
      tester,
    ) async {
      final year = DateTime.now().year;
      seedState(
        IncomeSuccess(
          allIncomes: [fakeIncome()],
          filteredIncomes: const [],
          selectedYear: year,
          availableYears: [year],
          availableMonths: const [5],
        ),
      );
      await pumpIncomeScreen(tester);
      await tester.pump();

      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.byType(IncomeFilterBar), findsOneWidget);
      expect(find.byType(IncomeTotalCard), findsNothing);
    });

    testWidgets('filtered items show filter bar, total card and PDF icon', (
      tester,
    ) async {
      seedState(fakeIncomeSuccess(incomes: [fakeIncome()]));
      await pumpIncomeScreen(tester);
      await tester.pump();

      expect(find.byType(IncomeFilterBar), findsOneWidget);
      expect(find.byType(IncomeTotalCard), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });
  });

  group('IncomeScreen export listener isolation', () {
    late StreamController<ExportState> exportController;

    setUp(() {
      exportController = StreamController<ExportState>.broadcast();
      registerFallbackValue(const ResetExportRequested());
      final seeded = fakeIncomeSuccess();
      when(() => mockIncomeBloc.state).thenReturn(seeded);
      whenListen(
        mockIncomeBloc,
        Stream<IncomeState>.value(seeded),
        initialState: seeded,
      );
      whenListen(
        mockExportBloc,
        exportController.stream,
        initialState: const ExportInitial(),
      );
    });

    tearDown(() async => exportController.close());

    Future<void> push(WidgetTester tester, ExportState state) async {
      exportController.add(state);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('ignores ExportFailure(stats)', (tester) async {
      await pumpIncomeScreen(tester);
      await tester.pump();

      await push(
        tester,
        const ExportFailure('boom', exportType: ExportType.stats),
      );

      expect(
        find.text('Failed to generate PDF. Please try again.'),
        findsNothing,
      );
      verifyNever(() => mockExportBloc.add(const ResetExportRequested()));
    });

    testWidgets('handles ExportFailure(income) once', (tester) async {
      await pumpIncomeScreen(tester);
      await tester.pump();

      await push(
        tester,
        const ExportFailure('boom', exportType: ExportType.income),
      );

      expect(
        find.text('Failed to generate PDF. Please try again.'),
        findsOneWidget,
      );
      verify(() => mockExportBloc.add(const ResetExportRequested())).called(1);
    });

    testWidgets('exports whole year on All months, no snackbar', (
      tester,
    ) async {
      await pumpIncomeScreen(tester);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.picture_as_pdf));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Please select a specific month to export.'),
        findsNothing,
      );
      final event =
          verify(
                () => mockExportBloc.add(
                  captureAny(that: isA<ExportIncomeStarted>()),
                ),
              ).captured.single
              as ExportIncomeStarted;
      expect(event.month, isNull);
    });
  });
}
