import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/exceptions/expense_exceptions.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/get_or_create_default_category_usecase.dart';
import 'package:weeklet/domain/usecases/expense/add_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/delete_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/get_all_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/expense/update_expense_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_event.dart';
import 'package:weeklet/presentation/blocs/expense/expense_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import '../../../helpers/fake_blocs.dart';

// ---------------------------------------------------------------------------
// File-private stubs
// ---------------------------------------------------------------------------

class _StubAddExpenseUseCase implements AddExpenseUseCase {
  bool shouldThrow = false;
  Object? throwable;
  AddExpenseParams? lastParams;

  @override
  Future<void> call(AddExpenseParams params) async {
    if (shouldThrow) throw throwable ?? Exception('stub error');
    lastParams = params;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubUpdateExpenseUseCase implements UpdateExpenseUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(Expense params) async {
    if (shouldThrow) throw Exception('update error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubDeleteExpenseUseCase implements DeleteExpenseUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(String params) async {
    if (shouldThrow) throw Exception('delete error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetAllExpensesUseCase implements GetAllExpensesUseCase {
  List<Expense> returnValue = const [];
  bool shouldThrow = false;

  @override
  Future<List<Expense>> call(NoParams params) async {
    if (shouldThrow) throw Exception('load error');
    return returnValue;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetOrCreateDefaultCategoryUseCase
    implements GetOrCreateDefaultCategoryUseCase {
  Category returnValue = _fakeDefaultCategory();
  int callCount = 0;
  String? lastLocalizedName;
  bool shouldThrow = false;
  Object? throwable;

  @override
  Future<Category> call(GetOrCreateDefaultCategoryParams params) async {
    callCount++;
    lastLocalizedName = params.localizedName;
    if (shouldThrow) throw throwable ?? Exception('default category error');
    return returnValue;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

Category _fakeDefaultCategory({String id = 'cat-default'}) =>
    Category(id: id, name: 'Daily', icon: 'home', createdAt: DateTime(2025));

Expense _fakeExpense({String id = 'exp-1'}) => Expense(
  id: id,
  amount: 100.0,
  description: 'Test expense',
  categoryId: 'cat-1',
  createdAt: DateTime(DateTime.now().year, 5, 1),
);

ExpenseSuccess _successSeed({List<Expense>? expenses}) {
  final list = expenses ?? [_fakeExpense()];
  return ExpenseSuccess(
    allExpenses: list,
    filteredExpenses: list,
    selectedYear: DateTime.now().year,
    selectedMonth: null,
    availableYears: [DateTime.now().year],
    availableMonths: const [5],
  );
}

// ---------------------------------------------------------------------------
// Shared stub references (reset in each group's setUp)
// ---------------------------------------------------------------------------

late _StubAddExpenseUseCase _stubAdd;
late _StubUpdateExpenseUseCase _stubUpdate;
late _StubDeleteExpenseUseCase _stubDelete;
late _StubGetAllExpensesUseCase _stubGet;
late _StubGetOrCreateDefaultCategoryUseCase _stubDefaultCategory;

ExpenseBloc _makeBloc() => ExpenseBloc(
  addExpenseUseCase: _stubAdd,
  updateExpenseUseCase: _stubUpdate,
  deleteExpenseUseCase: _stubDelete,
  getExpensesUseCase: _stubGet,
  getOrCreateDefaultCategoryUseCase: _stubDefaultCategory,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ExpenseBloc — initial state', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    test('initial state is ExpenseInitial', () {
      final bloc = _makeBloc();
      addTearDown(bloc.close);
      expect(bloc.state, const ExpenseInitial());
    });
  });

  group('ExpenseBloc — load', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'emits ExpenseLoading then ExpenseSuccess on success',
      setUp: () => _stubGet.returnValue = [_fakeExpense()],
      build: _makeBloc,
      act: (bloc) => bloc.add(const LoadExpensesRequested()),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      verify: (bloc) {
        expect((bloc.state as ExpenseSuccess).allExpenses.length, 1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits ExpenseLoading then ExpenseFailure when stub throws',
      setUp: () => _stubGet.shouldThrow = true,
      build: _makeBloc,
      act: (bloc) => bloc.add(const LoadExpensesRequested()),
      expect: () => [const ExpenseLoading(), isA<ExpenseFailure>()],
    );
  });

  group('ExpenseBloc — filter', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'FilterDateChanged by year filters expenses',
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) =>
          bloc.add(FilterDateChanged(year: DateTime.now().year)),
      expect: () => [isA<ExpenseSuccess>()],
      verify: (bloc) {
        final s = bloc.state as ExpenseSuccess;
        expect(s.filteredExpenses, isNotEmpty);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'FilterDateChanged by month filters to that month',
      build: _makeBloc,
      seed: () => _successSeed(expenses: [_fakeExpense()]),
      act: (bloc) => bloc.add(const FilterDateChanged(month: 5)),
      expect: () => [
        isA<ExpenseSuccess>().having(
          (s) => s.selectedMonth,
          'selectedMonth',
          5,
        ),
      ],
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'FilterDateChanged does nothing when not in ExpenseSuccess',
      build: _makeBloc,
      act: (bloc) => bloc.add(const FilterDateChanged(year: 2025)),
      expect: () => <ExpenseState>[],
    );
  });

  group('ExpenseBloc — add', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'AddExpenseStarted in ExpenseSuccess triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
        _stubGet.returnValue = [_fakeExpense()];
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: 'cat-1',
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'AddExpenseStarted validation exception sets actionError',
      setUp: () {
        _stubAdd.shouldThrow = true;
        _stubAdd.throwable = const ExpenseValidationException(
          ExpenseValidationError.emptyDescription,
        );
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: '',
          categoryId: 'cat-1',
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [
        isA<ExpenseSuccess>().having(
          (s) => s.actionError,
          'actionError',
          'emptyDescription',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'AddExpenseStarted generic exception sets actionError to genericError',
      setUp: () {
        _stubAdd.shouldThrow = true;
        _stubAdd.throwable = Exception('boom');
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: 'cat-1',
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [
        isA<ExpenseSuccess>().having(
          (s) => s.actionError,
          'actionError',
          'genericError',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'AddExpenseStarted silently ignored when not in ExpenseSuccess',
      build: _makeBloc,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: 'cat-1',
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => <ExpenseState>[],
    );
  });

  group('ExpenseBloc — update', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'UpdateExpenseStarted triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
        _stubGet.returnValue = [_fakeExpense()];
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) =>
          bloc.add(UpdateExpenseStarted(_fakeExpense())),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'UpdateExpenseStarted error sets actionError to genericError',
      setUp: () {
        _stubUpdate.shouldThrow = true;
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) =>
          bloc.add(UpdateExpenseStarted(_fakeExpense())),
      expect: () => [
        isA<ExpenseSuccess>().having(
          (s) => s.actionError,
          'actionError',
          'genericError',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );
  });

  group('ExpenseBloc — delete', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'DeleteExpenseStarted triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
        _stubGet.returnValue = [];
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(const DeleteExpenseStarted('exp-1')),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'DeleteExpenseStarted error sets actionError',
      setUp: () {
        _stubDelete.shouldThrow = true;
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(const DeleteExpenseStarted('exp-1')),
      expect: () => [
        isA<ExpenseSuccess>().having(
          (s) => s.actionError,
          'actionError',
          'genericError',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );
  });

  group('ExpenseBloc — clear error', () {
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
    });

    blocTest<ExpenseBloc, ExpenseState>(
      'ClearActionErrorRequested clears actionError',
      build: _makeBloc,
      seed: () => _successSeed().copyWith(
        actionError: 'emptyDescription',
        selectedMonth: _successSeed().selectedMonth,
      ),
      act: (bloc) => bloc.add(const ClearActionErrorRequested()),
      expect: () => [
        isA<ExpenseSuccess>().having(
          (s) => s.actionError,
          'actionError',
          isNull,
        ),
      ],
    );
  });

  // -------------------------------------------------------------------------
  // CAT-01 / D-11: the no-category fallback decision now lives in the Bloc.
  // -------------------------------------------------------------------------
  group('ExpenseBloc - CAT-01 default category resolution', () {
    late FakeCategoryBloc fakeCategoryBloc;

    // Registered at GROUP level, not via blocTest's inline `tearDown:`, which
    // runs inside the test body and is skipped by a failing expectation,
    // leaking GetIt registrations into the next test.
    setUp(() {
      _stubAdd = _StubAddExpenseUseCase();
      _stubUpdate = _StubUpdateExpenseUseCase();
      _stubDelete = _StubDeleteExpenseUseCase();
      _stubGet = _StubGetAllExpensesUseCase();
      _stubDefaultCategory = _StubGetOrCreateDefaultCategoryUseCase();
      _stubGet.returnValue = [_fakeExpense()];
      fakeCategoryBloc = FakeCategoryBloc();
      GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
    });

    tearDown(() async {
      await fakeCategoryBloc.close();
      await GetIt.instance.reset();
    });

    // Case 1
    blocTest<ExpenseBloc, ExpenseState>(
      'a non-null categoryId bypasses default resolution entirely',
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: 'cat-1',
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      verify: (_) {
        expect(_stubDefaultCategory.callCount, 0);
        expect(_stubAdd.lastParams?.categoryId, 'cat-1');
      },
    );

    // Case 2
    blocTest<ExpenseBloc, ExpenseState>(
      'a null categoryId resolves the default and files the expense there',
      setUp: () {
        GetIt.instance.registerSingleton<CategoryBloc>(fakeCategoryBloc);
        _stubDefaultCategory.returnValue = _fakeDefaultCategory(
          id: 'cat-default',
        );
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: null,
          defaultCategoryName: 'Zilnic',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      verify: (_) {
        expect(_stubDefaultCategory.callCount, 1);
        // The locale-resolved string is passed straight through, never a
        // hardcoded 'Daily' (threat T-14-05-03).
        expect(_stubDefaultCategory.lastLocalizedName, 'Zilnic');
        expect(_stubAdd.lastParams?.categoryId, 'cat-default');
      },
    );

    // Case 3 - regression guard for Root Cause 3 defect (b): the widget used
    // to await the fallback with no try/catch, so a thrown duplicateName
    // silently aborted the save with no feedback at all.
    blocTest<ExpenseBloc, ExpenseState>(
      'a CategoryValidationException during resolution becomes an actionError',
      setUp: () {
        GetIt.instance.registerSingleton<CategoryBloc>(fakeCategoryBloc);
        _stubDefaultCategory.shouldThrow = true;
        _stubDefaultCategory.throwable = const CategoryValidationException(
          CategoryValidationError.duplicateName,
        );
      },
      build: _makeBloc,
      seed: () => _successSeed().copyWith(selectedMonth: 5),
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: null,
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [
        isA<ExpenseSuccess>()
            .having((s) => s.actionError, 'actionError', 'duplicateName')
            .having((s) => s.selectedMonth, 'selectedMonth', 5),
      ],
      verify: (_) {
        expect(_stubAdd.lastParams, isNull);
      },
    );

    // Case 4
    blocTest<ExpenseBloc, ExpenseState>(
      'a generic failure during resolution becomes actionError genericError',
      setUp: () {
        GetIt.instance.registerSingleton<CategoryBloc>(fakeCategoryBloc);
        _stubDefaultCategory.shouldThrow = true;
        _stubDefaultCategory.throwable = Exception('boom');
      },
      build: _makeBloc,
      seed: () => _successSeed().copyWith(selectedMonth: 5),
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: null,
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [
        isA<ExpenseSuccess>()
            .having((s) => s.actionError, 'actionError', 'genericError')
            .having((s) => s.selectedMonth, 'selectedMonth', 5),
      ],
      verify: (_) {
        expect(_stubAdd.lastParams, isNull);
      },
    );

    // Case 5a
    blocTest<ExpenseBloc, ExpenseState>(
      'creating a default refreshes the category list via CategoryBloc',
      setUp: () =>
          GetIt.instance.registerSingleton<CategoryBloc>(fakeCategoryBloc),
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: null,
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      verify: (bloc) async {
        expect(_stubDefaultCategory.callCount, 1);
        // A GetIt StateError would have been swallowed by the generic catch
        // and surfaced here as actionError 'genericError'.
        expect((bloc.state as ExpenseSuccess).actionError, isNull);
        await pumpEventQueue();
        expect(fakeCategoryBloc.state, isA<CategoriesLoaded>());
      },
    );

    // Case 5b - the lookup is gated on the null path, so the common case
    // needs no CategoryBloc registration at all (threat T-14-05-04).
    blocTest<ExpenseBloc, ExpenseState>(
      'the non-null categoryId path never looks CategoryBloc up in GetIt',
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddExpenseStarted(
          amount: '100.00',
          description: 'Lunch',
          categoryId: 'cat-1',
          defaultCategoryName: 'Daily',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [const ExpenseLoading(), isA<ExpenseSuccess>()],
      verify: (bloc) {
        expect(GetIt.instance.isRegistered<CategoryBloc>(), isFalse);
        expect((bloc.state as ExpenseSuccess).actionError, isNull);
      },
    );
  });
}
