import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/add_expense_form_view.dart';
import '../../../helpers/test_app.dart';
import '../../../helpers/test_data.dart';

// ---------------------------------------------------------------------------
// Mock declarations
//
// Each mock implements the concrete BLoC class so that Dart's type system
// allows it to be passed to BlocProvider<XxxBloc>.value(value: ...).
// ---------------------------------------------------------------------------

class MockExpenseBloc extends MockBloc<ExpenseEvent, ExpenseState>
    implements ExpenseBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

// ---------------------------------------------------------------------------
// Stub use cases — registered in GetIt to guard _onSave alternate paths
// ---------------------------------------------------------------------------

class _StubAddCategoryUseCase implements AddCategoryUseCase {
  @override
  Future<void> call(AddCategoryParams params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetAllCategoriesUseCase implements GetAllCategoriesUseCase {
  @override
  Future<List<Category>> call(NoParams params) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockExpenseBloc mockExpenseBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsBloc mockSettingsBloc;

  setUpAll(() {
    // Initialize LocaleManager for date formatting in sub-widgets.
    LocaleManager().initialize(const Locale('en'));

    // Use concrete leaf-class instances as fallback values.
    registerFallbackValue(const LoadExpensesRequested());
    registerFallbackValue(const ExpenseLoading());
    registerFallbackValue(const GetAllCategoriesEvent());
    registerFallbackValue(const CategoryLoading());
    registerFallbackValue(const LoadSettingsRequested());
    registerFallbackValue(const SettingsLoading());
    registerFallbackValue(
      AddExpenseStarted(
        amount: '0',
        description: '',
        categoryId: '',
        defaultCategoryName: '',
        date: DateTime(2025),
      ),
    );
  });

  setUp(() {
    mockExpenseBloc = MockExpenseBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsBloc = MockSettingsBloc();

    // Default expense state is ExpenseInitial (not Loading) so that the save
    // button can be enabled (isLoading = false when state is not ExpenseLoading).
    when(() => mockExpenseBloc.state).thenReturn(const ExpenseInitial());
    whenListen(
      mockExpenseBloc,
      const Stream<ExpenseState>.empty(),
      initialState: const ExpenseInitial(),
    );

    when(() => mockCategoryBloc.state).thenReturn(const CategoryLoading());
    whenListen(
      mockCategoryBloc,
      const Stream<CategoryState>.empty(),
      initialState: const CategoryLoading(),
    );

    when(() => mockSettingsBloc.state)
        .thenReturn(SettingsLoaded(settings: Settings.defaults()));
    whenListen(
      mockSettingsBloc,
      const Stream<SettingsState>.empty(),
      initialState: SettingsLoaded(settings: Settings.defaults()),
    );

    // CRITICAL: CategoryBloc MUST be registered in GetIt BEFORE pumpWidget
    // because AddExpenseFormView.initState calls sl<CategoryBloc>().add(...)
    GetIt.instance.registerSingleton<CategoryBloc>(mockCategoryBloc);
    GetIt.instance.registerSingleton<ExpenseBloc>(mockExpenseBloc);
    GetIt.instance.registerSingleton<SettingsBloc>(mockSettingsBloc);

    // Stub use cases registered to prevent StateError if _onSave alternate
    // path (no 'Daily' category) is triggered.
    GetIt.instance.registerSingleton<AddCategoryUseCase>(
      _StubAddCategoryUseCase(),
    );
    GetIt.instance.registerSingleton<GetAllCategoriesUseCase>(
      _StubGetAllCategoriesUseCase(),
    );
  });

  tearDown(() async => GetIt.instance.reset());

  /// Seeds CategoryBloc with CategoriesLoaded containing a 'Daily' category
  /// so that _onSave uses the existing category without calling sl<AddCategoryUseCase>.
  Future<void> pumpFormView(WidgetTester tester) async {
    final dailyLoaded = CategoriesLoaded(
      categories: [fakeCategory(id: 'daily-1', name: 'Daily')],
    );

    when(() => mockCategoryBloc.state).thenReturn(dailyLoaded);
    whenListen(
      mockCategoryBloc,
      const Stream<CategoryState>.empty(),
      initialState: dailyLoaded,
    );

    await pumpApp(
      tester,
      const AddExpenseFormView(),
      providers: [
        BlocProvider<ExpenseBloc>.value(value: mockExpenseBloc),
        BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      ],
    );
  }

  group('AddExpenseFormView', () {
    testWidgets(
      'shows form fields when categories are loaded',
      (tester) async {
        await pumpFormView(tester);
        await tester.pump();

        // Amount and description fields are visible as TextFormField widgets
        expect(find.byType(TextFormField), findsWidgets);
      },
    );

    testWidgets(
      'shows validation error for empty amount on save attempt',
      (tester) async {
        await pumpFormView(tester);
        await tester.pump();

        // Enter text in the description field (index 1 of TextFormField widgets)
        // to trigger _hasInteracted = true via _descriptionController listener.
        // This enables the save button (isEnabled = true).
        // TextFormField order: [0] amount, [1] description, [2] date (readOnly)
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Test description',
        );
        await tester.pump();

        // Tap the save button (ElevatedButton inside ExpenseFormSubmitView).
        // The amount field is empty → validation fails → error message shown.
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Validation error for empty amount is shown.
        // l10n.validationRequired en text = 'This field is required'
        expect(find.text('This field is required'), findsWidgets);
      },
    );

    testWidgets(
      'dispatches AddExpenseStarted when valid form is submitted',
      (tester) async {
        await pumpFormView(tester);
        await tester.pump();

        // Enter a valid amount in the amount field (index 0).
        // Triggers _amountController listener → _hasInteracted = true.
        await tester.enterText(
          find.byType(TextFormField).first,
          '50',
        );
        await tester.pump();

        // Enter description text in the description field (index 1).
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Lunch',
        );
        await tester.pump();

        // Open the date picker by tapping the calendar icon (readOnly InputView).
        await tester.tap(find.byIcon(Icons.calendar_today_outlined));
        // Pump frames to allow the date picker dialog to appear and animate in.
        // Use finite durations rather than pumpAndSettle to avoid CommonDropdownButton
        // addPostFrameCallback loop causing an infinite pump cycle.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Confirm the currently selected (today's) date in the calendar dialog.
        final okButton = find.text('OK');
        expect(okButton, findsOneWidget);
        await tester.tap(okButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Change expense bloc state so that BlocListener (pop on success) does
        // not immediately close the form after dispatch.
        when(() => mockExpenseBloc.state)
            .thenReturn(fakeExpenseSuccess(expenses: []));

        // Tap the save button — form is valid, date is set, category is 'Daily'.
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Verify AddExpenseStarted was dispatched to ExpenseBloc (D-02).
        verify(
          () => mockExpenseBloc.add(any(that: isA<AddExpenseStarted>())),
        ).called(1);
      },
    );
  });
}
