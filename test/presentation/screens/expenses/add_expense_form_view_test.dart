import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weeklet/core/utils/locale_manager.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/settings.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_event.dart';
import 'package:weeklet/presentation/blocs/settings/settings_state.dart';
import 'package:weeklet/presentation/screens/expenses/widgets/add/expense_form_category_view.dart';
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
// Tests
//
// No use case is registered in GetIt on purpose: after 14-06 the form only
// validates and dispatches, so a surviving sl<XxxUseCase>() call would throw a
// GetIt StateError and fail the suite.
// ---------------------------------------------------------------------------

void main() {
  late MockExpenseBloc mockExpenseBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsBloc mockSettingsBloc;

  // Backs mockCategoryBloc.stream. A broadcast controller is required because
  // BlocListener only ever sees states emitted AFTER it subscribes; seeding an
  // initialState is not an emission. Events must therefore be pushed strictly
  // after pumpApp has returned.
  late StreamController<CategoryState> categoryStateController;

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
    categoryStateController = StreamController<CategoryState>.broadcast();

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
      categoryStateController.stream,
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

    // CRITICAL: CategoryBloc MUST be registered in GetIt BEFORE pumpWidget
    // because AddExpenseFormView.initState calls sl<CategoryBloc>().add(...)
    GetIt.instance.registerSingleton<CategoryBloc>(mockCategoryBloc);
    GetIt.instance.registerSingleton<ExpenseBloc>(mockExpenseBloc);
    GetIt.instance.registerSingleton<SettingsBloc>(mockSettingsBloc);
  });

  tearDown(() async {
    await categoryStateController.close();
    await GetIt.instance.reset();
  });

  /// Pumps the form with [initialState] as the CategoryBloc's current state.
  ///
  /// [initialState] is nullable rather than defaulted because the fallback is
  /// built from [fakeCategory] and is therefore not a compile-time constant.
  /// When omitted it falls back to a single seeded 'Daily' category, which is
  /// what the three original tests expect.
  Future<void> pumpFormView(
    WidgetTester tester, {
    CategoryState? initialState,
  }) async {
    final resolved =
        initialState ??
        CategoriesLoaded(
          categories: [fakeCategory(id: 'daily-1', name: 'Daily')],
        );

    when(() => mockCategoryBloc.state).thenReturn(resolved);
    whenListen(
      mockCategoryBloc,
      categoryStateController.stream,
      initialState: resolved,
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

  /// Reads the live category dropdown wrapper, which exposes the form's
  /// current `_selectedCategory` through its `selectedCategory` prop.
  ExpenseFormCategoryView categoryView(WidgetTester tester) =>
      tester.widget<ExpenseFormCategoryView>(
        find.byType(ExpenseFormCategoryView),
      );

  /// Invokes the live onChanged callback directly, which runs the real
  /// setState in _AddExpenseFormViewState. Driving the MenuAnchor dropdown
  /// would require overlay frames plus consumeOutsideTap handling, which this
  /// file deliberately avoids.
  Future<void> selectCategory(WidgetTester tester, Category category) async {
    categoryView(tester).onChanged(category);
    await tester.pump();
  }

  /// Fills amount, description and date so the form passes validation.
  /// Finite pumps only: CommonDropdownButton.build schedules an
  /// addPostFrameCallback on every build, so a settle-based pump would loop
  /// forever. Never introduce one in this file.
  Future<void> fillValidForm(WidgetTester tester) async {
    // TextFormField order: [0] amount, [1] description, [2] date (readOnly)
    await tester.enterText(find.byType(TextFormField).first, '50');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), 'Lunch');
    await tester.pump();

    // Open the date picker by tapping the calendar icon (readOnly InputView).
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Confirm the currently selected (today's) date in the calendar dialog.
    final okButton = find.text('OK');
    expect(okButton, findsOneWidget);
    await tester.tap(okButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  AddExpenseStarted capturedAddExpense() {
    final captured = verify(() => mockExpenseBloc.add(captureAny())).captured;
    return captured.whereType<AddExpenseStarted>().single;
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
      'dispatches AddExpenseStarted with the selected category id',
      (tester) async {
        await pumpFormView(tester);
        await tester.pump();

        await selectCategory(
          tester,
          fakeCategory(id: 'daily-1', name: 'Daily'),
        );
        await fillValidForm(tester);

        // Change expense bloc state so that BlocListener (pop on success) does
        // not immediately close the form after dispatch.
        when(
          () => mockExpenseBloc.state,
        ).thenReturn(fakeExpenseSuccess(expenses: []));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        final event = capturedAddExpense();
        expect(event.categoryId, 'daily-1');
        expect(event.defaultCategoryName, isNotEmpty);
      },
    );

    testWidgets(
      'dispatches a null categoryId when nothing is selected',
      (tester) async {
        await pumpFormView(tester);
        await tester.pump();

        await fillValidForm(tester);

        when(
          () => mockExpenseBloc.state,
        ).thenReturn(fakeExpenseSuccess(expenses: []));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // The widget resolves no fallback of its own: the BLoC owns that
        // decision now (CAT-01 / D-11).
        final event = capturedAddExpense();
        expect(event.categoryId, isNull);
      },
    );

    testWidgets(
      'auto-selects a category created mid-flow (D-10)',
      (tester) async {
        // Faithful shape: initState dispatches GetAllCategoriesEvent and the
        // bloc answers later, so the form starts on CategoryLoading.
        await pumpFormView(tester, initialState: const CategoryLoading());
        await tester.pump();

        categoryStateController.add(
          CategoriesLoaded(
            categories: [fakeCategory(id: 'cat-9', name: 'Groceries')],
            lastCreatedCategoryId: 'cat-9',
          ),
        );
        // First pump delivers the event and runs the listener's setState,
        // second pump rebuilds the subtree so the prop reflects it.
        await tester.pump();
        await tester.pump();

        expect(categoryView(tester).selectedCategory?.id, 'cat-9');
        verify(
          () => mockCategoryBloc.add(
            any(that: isA<ClearLastCreatedCategoryRequested>()),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'does not override a manual selection',
      (tester) async {
        final catA = fakeCategory(id: 'cat-a', name: 'Alpha');
        final catB = fakeCategory(id: 'cat-b', name: 'Beta');

        await pumpFormView(
          tester,
          initialState: CategoriesLoaded(categories: [catA, catB]),
        );
        await tester.pump();

        await selectCategory(tester, catA);

        categoryStateController.add(
          CategoriesLoaded(
            categories: [catA, catB],
            lastCreatedCategoryId: catB.id,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(categoryView(tester).selectedCategory?.id, catA.id);
        verifyNever(
          () => mockCategoryBloc.add(
            any(that: isA<ClearLastCreatedCategoryRequested>()),
          ),
        );
      },
    );

    testWidgets(
      'preselects the default category while it is the only category',
      (tester) async {
        await pumpFormView(tester, initialState: const CategoryLoading());
        await tester.pump();

        categoryStateController.add(
          CategoriesLoaded(
            categories: [fakeCategory(id: 'daily-1', name: 'Daily')],
            defaultCategoryId: 'daily-1',
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(categoryView(tester).selectedCategory?.id, 'daily-1');
        expect(find.text('Select Category'), findsNothing);
      },
    );

    testWidgets(
      'shows Select Category when another category exists besides default',
      (tester) async {
        await pumpFormView(tester, initialState: const CategoryLoading());
        await tester.pump();

        categoryStateController.add(
          CategoriesLoaded(
            categories: [
              fakeCategory(id: 'daily-1', name: 'Daily'),
              fakeCategory(id: 'cat-2', name: 'Groceries'),
            ],
            defaultCategoryId: 'daily-1',
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(categoryView(tester).selectedCategory, isNull);
        expect(find.text('Select Category'), findsOneWidget);
      },
    );

    testWidgets(
      'default preselect never overrides a selection and applies once',
      (tester) async {
        final daily = fakeCategory(id: 'daily-1', name: 'Daily');
        final other = fakeCategory(id: 'cat-2', name: 'Groceries');

        await pumpFormView(tester, initialState: const CategoryLoading());
        await tester.pump();

        // Manual selection first; a later sole-default load must not replace.
        await selectCategory(tester, other);
        categoryStateController.add(
          CategoriesLoaded(categories: [daily], defaultCategoryId: 'daily-1'),
        );
        await tester.pump();
        await tester.pump();
        expect(categoryView(tester).selectedCategory?.id, 'cat-2');
      },
    );

    testWidgets(
      'default preselect applies at most once per form instance',
      (tester) async {
        final daily = fakeCategory(id: 'daily-1', name: 'Daily');

        await pumpFormView(tester, initialState: const CategoryLoading());
        await tester.pump();

        categoryStateController.add(
          CategoriesLoaded(categories: [daily], defaultCategoryId: 'daily-1'),
        );
        await tester.pump();
        await tester.pump();
        expect(categoryView(tester).selectedCategory?.id, 'daily-1');

        // User clears the selection, then a reload arrives: no re-apply.
        categoryView(tester).onChanged(null);
        await tester.pump();
        categoryStateController.add(
          CategoriesLoaded(categories: [daily], defaultCategoryId: 'daily-1'),
        );
        await tester.pump();
        await tester.pump();
        expect(categoryView(tester).selectedCategory, isNull);
      },
    );

    testWidgets(
      'no GetIt lookup of use cases remains',
      (tester) async {
        // Only the three BLoCs are registered in GetIt. A surviving
        // sl<AddCategoryUseCase>() / sl<GetAllCategoriesUseCase>() call in
        // _onSave would throw a GetIt StateError here.
        await pumpFormView(tester);
        await tester.pump();

        await fillValidForm(tester);

        when(
          () => mockExpenseBloc.state,
        ).thenReturn(fakeExpenseSuccess(expenses: []));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(capturedAddExpense().categoryId, isNull);
      },
    );
  });
}
