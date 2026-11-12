import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/income/widgets/add/income_form_submit_view.dart';
import 'package:weeklet/presentation/screens/income/widgets/add_income_form_view.dart';
import '../../../../helpers/test_app.dart';

class MockIncomeBloc extends MockBloc<IncomeEvent, IncomeState>
    implements IncomeBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

IncomeSuccess _success({String? formError}) => IncomeSuccess(
  allIncomes: const [],
  filteredIncomes: const [],
  selectedYear: 2025,
  availableYears: const [2025],
  availableMonths: const [],
  formError: formError,
);

void main() {
  late MockIncomeBloc mockIncomeBloc;
  late MockSettingsBloc mockSettingsBloc;
  late StreamController<IncomeState> incomeController;

  setUpAll(() {
    LocaleManager().initialize(const Locale('en'));
    registerFallbackValue(const ClearIncomeFormErrorRequested());
    registerFallbackValue(const IncomeLoading());
  });

  setUp(() {
    mockIncomeBloc = MockIncomeBloc();
    mockSettingsBloc = MockSettingsBloc();
    incomeController = StreamController<IncomeState>.broadcast();

    when(
      () => mockSettingsBloc.state,
    ).thenReturn(SettingsLoaded(settings: Settings.defaults()));
    whenListen(
      mockSettingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: SettingsLoaded(settings: Settings.defaults()),
    );
  });

  tearDown(() async {
    await incomeController.close();
  });

  /// Opens the form as a pushed route (so pop is observable) with
  /// [initial] as the bloc's current state.
  Future<void> openForm(
    WidgetTester tester, {
    IncomeState initial = const IncomeSuccess(
      allIncomes: [],
      filteredIncomes: [],
      selectedYear: 2025,
      availableYears: [2025],
      availableMonths: [],
    ),
  }) async {
    when(() => mockIncomeBloc.state).thenReturn(initial);
    whenListen(
      mockIncomeBloc,
      incomeController.stream,
      initialState: initial,
    );

    await pumpApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddIncomeFormView(),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      providers: [
        BlocProvider<IncomeBloc>.value(value: mockIncomeBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AddIncomeFormView), findsOneWidget);
  }

  Future<void> emit(WidgetTester tester, IncomeState state) async {
    incomeController.add(state);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(AddIncomeFormView)));

  Future<void> enterAmount(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField).first, text);
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  }

  /// Fills a valid amount and taps Save, so the form is waiting on the bloc.
  Future<void> submit(WidgetTester tester) async {
    await enterAmount(tester, '50');
    await tapSave(tester);
  }

  testWidgets('pops on Loading -> Success after Save', (tester) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, const IncomeLoading());
    await emit(tester, _success());
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeFormView), findsNothing);
  });

  testWidgets('does not pop on Loading -> Success without a Save', (
    tester,
  ) async {
    await openForm(tester);
    await enterAmount(tester, '50');
    await emit(tester, const IncomeLoading());
    await emit(tester, _success());
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeFormView), findsOneWidget);
  });

  testWidgets('ignores a formError when the form did not submit', (
    tester,
  ) async {
    await openForm(tester);
    await emit(tester, _success(formError: 'invalidAmount'));

    expect(find.text(l10n(tester).errorInvalidAmount), findsNothing);
  });

  testWidgets('does not pop when an error is cleared (prev not Loading)', (
    tester,
  ) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, _success(formError: 'invalidAmount'));
    await emit(tester, _success());
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeFormView), findsOneWidget);
  });

  testWidgets('invalidAmount shows under the amount field', (tester) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, _success(formError: 'invalidAmount'));

    expect(find.byType(AddIncomeFormView), findsOneWidget);
    expect(find.text(l10n(tester).errorInvalidAmount), findsOneWidget);
    expect(find.text(l10n(tester).errorGeneric), findsNothing);
  });

  testWidgets('emptyDescription shows under the description field', (
    tester,
  ) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, _success(formError: 'emptyDescription'));

    expect(find.text(l10n(tester).errorEmptyDescription), findsOneWidget);
    expect(find.text(l10n(tester).errorGeneric), findsNothing);
  });

  testWidgets('other formError shows general error above Save', (
    tester,
  ) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, _success(formError: 'genericError'));

    expect(
      find.descendant(
        of: find.byType(IncomeFormSubmitView),
        matching: find.text(l10n(tester).errorGeneric),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n(tester).errorInvalidAmount), findsNothing);
    expect(find.text(l10n(tester).errorEmptyDescription), findsNothing);
    expect(find.byType(AddIncomeFormView), findsOneWidget);
  });

  testWidgets('editing the amount clears the amount field error', (
    tester,
  ) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, _success(formError: 'invalidAmount'));
    expect(find.text(l10n(tester).errorInvalidAmount), findsOneWidget);

    await enterAmount(tester, '5');

    expect(find.text(l10n(tester).errorInvalidAmount), findsNothing);
  });

  testWidgets('Save clears general error and dispatches Clear before Add', (
    tester,
  ) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, _success(formError: 'genericError'));
    expect(find.text(l10n(tester).errorGeneric), findsOneWidget);

    await tapSave(tester);

    expect(find.text(l10n(tester).errorGeneric), findsNothing);
    verifyInOrder([
      () => mockIncomeBloc.add(any(that: isA<ClearIncomeFormErrorRequested>())),
      () => mockIncomeBloc.add(any(that: isA<AddIncomeStarted>())),
    ]);
  });

  testWidgets('a second Save tap while submitting is ignored', (
    tester,
  ) async {
    await openForm(tester);
    await enterAmount(tester, '50');

    await tapSave(tester);
    await tapSave(tester);

    verify(
      () => mockIncomeBloc.add(any(that: isA<AddIncomeStarted>())),
    ).called(1);
  });

  testWidgets('pops when the reload after Save fails', (tester) async {
    await openForm(tester);
    await submit(tester);
    await emit(tester, const IncomeLoading());
    await emit(tester, const IncomeFailure('boom'));
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeFormView), findsNothing);
  });

  testWidgets('Save is disabled while the bloc is in IncomeFailure', (
    tester,
  ) async {
    await openForm(tester, initial: const IncomeFailure('boom'));
    await enterAmount(tester, '50');

    final save = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(save.onPressed, isNull);
  });

  testWidgets('reports open and close to the bloc', (tester) async {
    await openForm(tester);
    verify(
      () => mockIncomeBloc.add(any(that: isA<IncomeFormOpened>())),
    ).called(1);

    await submit(tester);
    await emit(tester, const IncomeLoading());
    await emit(tester, _success());
    await tester.pumpAndSettle();

    verify(
      () => mockIncomeBloc.add(any(that: isA<IncomeFormClosed>())),
    ).called(1);
  });

  testWidgets('description field shows the income hint', (tester) async {
    await openForm(tester);

    expect(find.text(l10n(tester).incomeDescriptionFieldHint), findsOneWidget);
  });
}
