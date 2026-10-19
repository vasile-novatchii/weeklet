import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/core/utils/number_formatter.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_event.dart';
import 'package:weeklet/presentation/blocs/export/export_state.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/expenses/expenses_screen.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/expense_filter_bar.dart';
import 'package:weeklet/presentation/widgets/common/common_dropdown_button.dart';
import 'package:weeklet/presentation/widgets/common/empty_state_view.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/test_data.dart';

// ---------------------------------------------------------------------------
// Mock declarations
//
// Each mock implements the concrete BLoC class so that Dart's type system
// allows it to be passed to BlocProvider<XxxBloc>.value(value: ...).
// The `Mock` base class intercepts all method calls via noSuchMethod so that
// no concrete implementation is required despite the `implements` clause.
// ---------------------------------------------------------------------------

class MockExpenseBloc extends MockBloc<ExpenseEvent, ExpenseState>
    implements ExpenseBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockIncomeBloc extends MockBloc<IncomeEvent, IncomeState>
    implements IncomeBloc {}

class MockExportBloc extends MockBloc<ExportEvent, ExportState>
    implements ExportBloc {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockExpenseBloc mockExpenseBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockExportBloc mockExportBloc;
  late MockIncomeBloc mockIncomeBloc;

  setUpAll(() {
    // Initialize LocaleManager so that date/locale formatting in sub-widgets
    // (e.g., ExpenseDayGroupView) does not throw LateInitializationError.
    LocaleManager().initialize(const Locale('en'));

    // Use concrete leaf-class instances as fallback values (sealed classes
    // cannot be implemented outside their library, so Fake subclasses are not
    // used here; concrete instances satisfy mocktail's any() matchers).
    registerFallbackValue(const LoadExpensesRequested());
    registerFallbackValue(const ExpenseLoading());
    registerFallbackValue(const GetAllCategoriesEvent());
    registerFallbackValue(const CategoryLoading());
    registerFallbackValue(const LoadSettingsRequested());
    registerFallbackValue(const SettingsLoading());
    registerFallbackValue(const ResetExportRequested());
    registerFallbackValue(const ExportInitial());
  });

  setUp(() {
    mockExpenseBloc = MockExpenseBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockExportBloc = MockExportBloc();
    mockIncomeBloc = MockIncomeBloc();

    final defaultIncome = fakeIncomeSuccess(incomes: []);
    when(() => mockIncomeBloc.state).thenReturn(defaultIncome);
    whenListen(
      mockIncomeBloc,
      const Stream<IncomeState>.empty(),
      initialState: defaultIncome,
    );

    // Wire default states and streams
    when(() => mockExpenseBloc.state).thenReturn(const ExpenseLoading());
    whenListen(
      mockExpenseBloc,
      const Stream<ExpenseState>.empty(),
      initialState: const ExpenseLoading(),
    );

    when(() => mockCategoryBloc.state).thenReturn(const CategoryLoading());
    whenListen(
      mockCategoryBloc,
      const Stream<CategoryState>.empty(),
      initialState: const CategoryLoading(),
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

    // expenses_screen.dart has no sl<> calls in initState; we register the
    // mock instances so that any sub-widget that calls sl<> won't throw.
    // MockExpenseBloc/MockCategoryBloc implement the real class types so the
    // GetIt type constraint is satisfied.
    GetIt.instance.registerSingleton<ExpenseBloc>(mockExpenseBloc);
    GetIt.instance.registerSingleton<CategoryBloc>(mockCategoryBloc);
  });

  tearDown(() async => GetIt.instance.reset());

  Future<void> pumpExpensesScreen(WidgetTester tester) => pumpApp(
    tester,
    const ExpensesScreen(),
    providers: [
      BlocProvider<ExpenseBloc>.value(value: mockExpenseBloc),
      BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
      BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      BlocProvider<ExportBloc>.value(value: mockExportBloc),
      BlocProvider<IncomeBloc>.value(value: mockIncomeBloc),
    ],
  );

  group('ExpensesScreen', () {
    testWidgets(
      'shows CircularProgressIndicator when state is ExpenseLoading',
      (tester) async {
        // Default setUp seed is ExpenseLoading — no override needed
        await pumpExpensesScreen(tester);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows EmptyStateView when filteredExpenses is empty and categories are loaded',
      (tester) async {
        final emptySuccess = fakeExpenseSuccess(expenses: []);

        when(() => mockExpenseBloc.state).thenReturn(emptySuccess);
        whenListen(
          mockExpenseBloc,
          const Stream<ExpenseState>.empty(),
          initialState: emptySuccess,
        );

        when(() => mockCategoryBloc.state).thenReturn(
          CategoriesLoaded(categories: [fakeCategory()]),
        );
        whenListen(
          mockCategoryBloc,
          const Stream<CategoryState>.empty(),
          initialState: CategoriesLoaded(categories: [fakeCategory()]),
        );

        await pumpExpensesScreen(tester);
        await tester.pump();

        expect(find.byType(EmptyStateView), findsOneWidget);
      },
    );

    testWidgets(
      'shows expense list (no loading indicator) when filteredExpenses is non-empty',
      (tester) async {
        final listSuccess = fakeExpenseSuccess(expenses: [fakeExpense()]);

        when(() => mockExpenseBloc.state).thenReturn(listSuccess);
        whenListen(
          mockExpenseBloc,
          const Stream<ExpenseState>.empty(),
          initialState: listSuccess,
        );

        when(() => mockCategoryBloc.state).thenReturn(
          CategoriesLoaded(categories: [fakeCategory()]),
        );
        whenListen(
          mockCategoryBloc,
          const Stream<CategoryState>.empty(),
          initialState: CategoriesLoaded(categories: [fakeCategory()]),
        );

        await pumpExpensesScreen(tester);
        await tester.pump();

        // Loading indicator and empty state are absent — list is rendered
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(EmptyStateView), findsNothing);
      },
    );

    testWidgets(
      'renders filter bar dropdowns when expenses are loaded',
      (tester) async {
        final listSuccess = fakeExpenseSuccess(expenses: [fakeExpense()]);

        when(() => mockExpenseBloc.state).thenReturn(listSuccess);
        whenListen(
          mockExpenseBloc,
          const Stream<ExpenseState>.empty(),
          initialState: listSuccess,
        );

        when(() => mockCategoryBloc.state).thenReturn(
          CategoriesLoaded(categories: [fakeCategory()]),
        );
        whenListen(
          mockCategoryBloc,
          const Stream<CategoryState>.empty(),
          initialState: CategoriesLoaded(categories: [fakeCategory()]),
        );

        await pumpExpensesScreen(tester);
        await tester.pump();

        // D-02 event-dispatch coverage for ExpensesScreen is provided by
        // add_expense_form_view_test.dart Task 2 (AddExpenseStarted verify).
        // This test verifies rendering only: ExpenseFilterBar is present when
        // ExpenseSuccess has data (filter bar renders CommonDropdownButton
        // widgets for month and year selection).
        expect(
          find.byWidgetPredicate((w) => w is CommonDropdownButton),
          findsWidgets,
        );
      },
    );
  });

  group('ExpensesScreen filter bar visibility', () {
    void seedStates(ExpenseState expenseState) {
      when(() => mockExpenseBloc.state).thenReturn(expenseState);
      whenListen(
        mockExpenseBloc,
        const Stream<ExpenseState>.empty(),
        initialState: expenseState,
      );
      final cats = CategoriesLoaded(categories: [fakeCategory()]);
      when(() => mockCategoryBloc.state).thenReturn(cats);
      whenListen(
        mockCategoryBloc,
        const Stream<CategoryState>.empty(),
        initialState: cats,
      );
    }

    testWidgets('kept while loading', (tester) async {
      await pumpExpensesScreen(tester);
      await tester.pump();
      expect(find.byType(ExpenseFilterBar), findsOneWidget);
    });

    testWidgets('kept on failure', (tester) async {
      seedStates(const ExpenseFailure('x'));
      await pumpExpensesScreen(tester);
      await tester.pump();
      expect(find.byType(ExpenseFilterBar), findsOneWidget);
    });

    testWidgets('hidden when no expense exists in any period', (tester) async {
      seedStates(fakeExpenseSuccess(expenses: []));
      await pumpExpensesScreen(tester);
      await tester.pump();
      expect(find.byType(ExpenseFilterBar), findsNothing);
      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('kept when selected period is empty but others have data', (
      tester,
    ) async {
      seedStates(
        ExpenseSuccess(
          allExpenses: [fakeExpense()],
          filteredExpenses: const [],
          selectedYear: DateTime.now().year,
          availableYears: [DateTime.now().year],
          availableMonths: const [5],
        ),
      );
      await pumpExpensesScreen(tester);
      await tester.pump();
      expect(find.byType(ExpenseFilterBar), findsOneWidget);
      expect(find.byType(EmptyStateView), findsOneWidget);
    });
  });

  group('ExpensesScreen export listener isolation', () {
    late StreamController<ExportState> exportController;

    setUp(() {
      exportController = StreamController<ExportState>.broadcast();
      registerFallbackValue(const ResetExportRequested());
      final seeded = fakeExpenseSuccess();
      when(() => mockExpenseBloc.state).thenReturn(seeded);
      whenListen(
        mockExpenseBloc,
        Stream<ExpenseState>.value(seeded),
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
      await pumpExpensesScreen(tester);
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

    testWidgets('handles ExportFailure(expenses) once', (tester) async {
      await pumpExpensesScreen(tester);
      await tester.pump();

      await push(
        tester,
        const ExportFailure('boom', exportType: ExportType.expenses),
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
      await pumpExpensesScreen(tester);
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
                  captureAny(that: isA<ExportExpensesStarted>()),
                ),
              ).captured.single
              as ExportExpensesStarted;
      expect(event.month, isNull);
    });
  });

  group('ExpensesScreen income subtitle', () {
    final year = DateTime.now().year;
    final symbol = SettingsLoaded(settings: Settings.defaults()).currencySymbol;
    final march = Income(
      id: 'i-mar',
      amount: 100.50,
      description: 'March',
      date: DateTime(year, 3, 10),
      createdAt: DateTime(year, 3, 10),
    );
    final april = Income(
      id: 'i-apr',
      amount: 40,
      description: 'April',
      date: DateTime(year, 4, 10),
      createdAt: DateTime(year, 4, 10),
    );

    ExpenseSuccess expenseSuccess({int? month}) => ExpenseSuccess(
      allExpenses: const [],
      filteredExpenses: const [],
      selectedYear: year,
      selectedMonth: month,
      availableYears: [year],
      availableMonths: const [3, 4],
    );

    void seed({required ExpenseState expense, required IncomeState income}) {
      when(() => mockExpenseBloc.state).thenReturn(expense);
      whenListen(
        mockExpenseBloc,
        const Stream<ExpenseState>.empty(),
        initialState: expense,
      );
      when(() => mockIncomeBloc.state).thenReturn(income);
      whenListen(
        mockIncomeBloc,
        const Stream<IncomeState>.empty(),
        initialState: income,
      );
    }

    IncomeSuccess incomeSuccess(List<Income> list) =>
        fakeIncomeSuccess(incomes: list);

    testWidgets('shows selected month total', (tester) async {
      seed(
        expense: expenseSuccess(month: 3),
        income: incomeSuccess([march, april]),
      );
      await pumpExpensesScreen(tester);
      await tester.pump();

      final amount = NumberFormatter.formatCurrency(100.50, symbol);
      expect(find.text('Income: $amount'), findsOneWidget);
      expect(find.text('My Expenses'), findsOneWidget);
    });

    testWidgets('shows whole-year total when month is null', (tester) async {
      seed(
        expense: expenseSuccess(),
        income: incomeSuccess([march, april]),
      );
      await pumpExpensesScreen(tester);
      await tester.pump();

      final amount = NumberFormatter.formatCurrency(140.50, symbol);
      expect(find.text('Income: $amount'), findsOneWidget);
    });

    testWidgets('hidden when period has no income', (tester) async {
      seed(
        expense: expenseSuccess(month: 3),
        income: incomeSuccess([april]),
      );
      await pumpExpensesScreen(tester);
      await tester.pump();

      expect(find.textContaining('Income:'), findsNothing);
    });

    testWidgets('hidden when IncomeState is loading', (tester) async {
      seed(
        expense: expenseSuccess(month: 3),
        income: const IncomeLoading(),
      );
      await pumpExpensesScreen(tester);
      await tester.pump();

      expect(find.textContaining('Income:'), findsNothing);
    });

    testWidgets('hidden when ExpenseState is not success', (tester) async {
      seed(
        expense: const ExpenseLoading(),
        income: incomeSuccess([march]),
      );
      await pumpExpensesScreen(tester);
      await tester.pump();

      expect(find.textContaining('Income:'), findsNothing);
    });
  });
}
