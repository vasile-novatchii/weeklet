import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/exceptions/income_exceptions.dart';
import 'package:weeklet/domain/usecases/income/add_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/delete_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/get_incomes_use_case.dart';
import 'package:weeklet/domain/usecases/income/update_income_use_case.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_event.dart';
import 'package:weeklet/presentation/blocs/income/income_state.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import '../../../helpers/fake_blocs.dart';

// ---------------------------------------------------------------------------
// File-private stubs
// ---------------------------------------------------------------------------

// Plain class stubs — no UseCase<T,P> interface (per codebase inconsistency).
// noSuchMethod satisfies the concrete class `repository` field constraint.

class _StubGetIncomesUseCase implements GetIncomesUseCase {
  List<Income> returnValue = const [];
  bool shouldThrow = false;

  @override
  Future<List<Income>> call() async {
    if (shouldThrow) throw Exception('load error');
    return returnValue;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubUpdateIncomeUseCase implements UpdateIncomeUseCase {
  bool shouldThrow = false;
  Object? throwable;

  @override
  Future<void> call(Income params) async {
    if (shouldThrow) throw throwable ?? Exception('update error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubDeleteIncomeUseCase implements DeleteIncomeUseCase {
  bool shouldThrow = false;

  @override
  Future<void> call(String id) async {
    if (shouldThrow) throw Exception('delete error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// AddIncomeUseCase implements UseCase<void, AddIncomeParams>.
class _StubAddIncomeUseCase implements AddIncomeUseCase {
  bool shouldThrow = false;
  Object? throwable;

  @override
  Future<void> call(AddIncomeParams params) async {
    if (shouldThrow) throw throwable ?? Exception('add error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

Income _fakeIncome({String id = 'inc-1', DateTime? date}) {
  final effectiveDate = date ?? DateTime(DateTime.now().year, 5, 1);
  return Income(
    id: id,
    amount: 500.0,
    description: 'Salary',
    date: effectiveDate,
    createdAt: effectiveDate,
  );
}

IncomeSuccess _successSeed({List<Income>? incomes}) {
  final list = incomes ?? [_fakeIncome()];
  return IncomeSuccess(
    allIncomes: list,
    filteredIncomes: list,
    selectedYear: DateTime.now().year,
    selectedMonth: null,
    availableYears: [DateTime.now().year],
    availableMonths: const [5],
  );
}

// ---------------------------------------------------------------------------
// Shared stub references (reset in each group's setUp)
// ---------------------------------------------------------------------------

late _StubAddIncomeUseCase _stubAdd;
late _StubUpdateIncomeUseCase _stubUpdate;
late _StubDeleteIncomeUseCase _stubDelete;
late _StubGetIncomesUseCase _stubGet;

IncomeBloc _makeBloc() => IncomeBloc(
  addIncomeUseCase: _stubAdd,
  updateIncomeUseCase: _stubUpdate,
  deleteIncomeUseCase: _stubDelete,
  getIncomesUseCase: _stubGet,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('IncomeBloc — initial state', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    test('initial state is IncomeInitial', () {
      final bloc = _makeBloc();
      addTearDown(bloc.close);
      expect(bloc.state, const IncomeInitial());
    });
  });

  group('IncomeBloc — load', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    blocTest<IncomeBloc, IncomeState>(
      'emits IncomeLoading then IncomeSuccess on success',
      setUp: () => _stubGet.returnValue = [_fakeIncome()],
      build: _makeBloc,
      act: (bloc) => bloc.add(const LoadIncomesRequested()),
      expect: () => [const IncomeLoading(), isA<IncomeSuccess>()],
      verify: (bloc) {
        expect((bloc.state as IncomeSuccess).allIncomes.length, 1);
      },
    );

    blocTest<IncomeBloc, IncomeState>(
      'emits IncomeLoading then IncomeFailure when stub throws',
      setUp: () => _stubGet.shouldThrow = true,
      build: _makeBloc,
      act: (bloc) => bloc.add(const LoadIncomesRequested()),
      expect: () => [const IncomeLoading(), isA<IncomeFailure>()],
    );
  });

  group('IncomeBloc — filter', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    blocTest<IncomeBloc, IncomeState>(
      'IncomeFilterDateChanged by year filters incomes',
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) =>
          bloc.add(IncomeFilterDateChanged(year: DateTime.now().year)),
      expect: () => [isA<IncomeSuccess>()],
      verify: (bloc) {
        final s = bloc.state as IncomeSuccess;
        expect(s.filteredIncomes, isNotEmpty);
      },
    );

    blocTest<IncomeBloc, IncomeState>(
      'IncomeFilterDateChanged by month filters to that month',
      build: _makeBloc,
      seed: () => _successSeed(incomes: [_fakeIncome()]),
      act: (bloc) => bloc.add(const IncomeFilterDateChanged(month: 5)),
      expect: () => [
        isA<IncomeSuccess>().having(
          (s) => s.selectedMonth,
          'selectedMonth',
          5,
        ),
      ],
    );

    blocTest<IncomeBloc, IncomeState>(
      'IncomeFilterDateChanged does nothing when not in IncomeSuccess',
      build: _makeBloc,
      act: (bloc) => bloc.add(const IncomeFilterDateChanged(year: 2025)),
      expect: () => <IncomeState>[],
    );
  });

  group('IncomeBloc — add', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    blocTest<IncomeBloc, IncomeState>(
      'AddIncomeStarted in IncomeSuccess triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
        _stubGet.returnValue = [_fakeIncome()];
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [const IncomeLoading(), isA<IncomeSuccess>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<IncomeBloc, IncomeState>(
      'AddIncomeStarted validation exception sets formError',
      setUp: () {
        _stubAdd.shouldThrow = true;
        _stubAdd.throwable = const IncomeValidationException(
          IncomeValidationError.emptyDescription,
        );
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: '',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [
        isA<IncomeSuccess>().having(
          (s) => s.formError,
          'formError',
          'emptyDescription',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<IncomeBloc, IncomeState>(
      'AddIncomeStarted generic exception sets formError to genericError',
      setUp: () {
        _stubAdd.shouldThrow = true;
        _stubAdd.throwable = Exception('boom');
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => [
        isA<IncomeSuccess>().having(
          (s) => s.formError,
          'formError',
          'genericError',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<IncomeBloc, IncomeState>(
      'AddIncomeStarted silently ignored when not in IncomeSuccess',
      build: _makeBloc,
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(DateTime.now().year, 5, 1),
        ),
      ),
      expect: () => <IncomeState>[],
    );
  });

  group('IncomeBloc — update', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    blocTest<IncomeBloc, IncomeState>(
      'UpdateIncomeStarted triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
        _stubGet.returnValue = [_fakeIncome()];
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(UpdateIncomeStarted(_fakeIncome())),
      expect: () => [const IncomeLoading(), isA<IncomeSuccess>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<IncomeBloc, IncomeState>(
      'UpdateIncomeStarted error sets formError to genericError',
      setUp: () {
        _stubUpdate.shouldThrow = true;
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(UpdateIncomeStarted(_fakeIncome())),
      expect: () => [
        isA<IncomeSuccess>().having(
          (s) => s.formError,
          'formError',
          'genericError',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<IncomeBloc, IncomeState>(
      'UpdateIncomeStarted validation exception sets formError',
      setUp: () {
        _stubUpdate.throwable = const IncomeValidationException(
          IncomeValidationError.invalidAmount,
        );
        _stubUpdate.shouldThrow = true;
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(UpdateIncomeStarted(_fakeIncome())),
      expect: () => [
        isA<IncomeSuccess>()
            .having((s) => s.formError, 'formError', 'invalidAmount')
            .having((s) => s.actionError, 'actionError', isNull),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );
  });

  group('IncomeBloc — delete', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    blocTest<IncomeBloc, IncomeState>(
      'DeleteIncomeStarted triggers reload',
      setUp: () {
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
        _stubGet.returnValue = [];
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(const DeleteIncomeStarted('inc-1')),
      expect: () => [const IncomeLoading(), isA<IncomeSuccess>()],
      tearDown: () async => GetIt.instance.reset(),
    );

    blocTest<IncomeBloc, IncomeState>(
      'DeleteIncomeStarted error sets actionError',
      setUp: () {
        _stubDelete.shouldThrow = true;
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: _successSeed,
      act: (bloc) => bloc.add(const DeleteIncomeStarted('inc-1')),
      expect: () => [
        isA<IncomeSuccess>().having(
          (s) => s.actionError,
          'actionError',
          'genericError',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );
  });

  group('IncomeBloc — clear error', () {
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
    });

    blocTest<IncomeBloc, IncomeState>(
      'ClearIncomeActionErrorRequested clears actionError',
      build: _makeBloc,
      seed: () => _successSeed().copyWith(
        actionError: 'emptyDescription',
        selectedMonth: _successSeed().selectedMonth,
      ),
      act: (bloc) => bloc.add(const ClearIncomeActionErrorRequested()),
      expect: () => [
        isA<IncomeSuccess>().having(
          (s) => s.actionError,
          'actionError',
          isNull,
        ),
      ],
    );

    blocTest<IncomeBloc, IncomeState>(
      'ClearIncomeFormErrorRequested clears formError and keeps All months',
      build: _makeBloc,
      seed: () => _successSeed().copyWith(
        formError: 'emptyDescription',
        selectedMonth: null,
      ),
      act: (bloc) => bloc.add(const ClearIncomeFormErrorRequested()),
      expect: () => [
        isA<IncomeSuccess>()
            .having((s) => s.formError, 'formError', isNull)
            .having((s) => s.selectedMonth, 'selectedMonth', isNull),
      ],
    );

    blocTest<IncomeBloc, IncomeState>(
      'ClearIncomeFormErrorRequested lands before a failing add result',
      setUp: () {
        _stubAdd.shouldThrow = true;
        _stubAdd.throwable = const IncomeValidationException(
          IncomeValidationError.invalidAmount,
        );
        GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
      },
      build: _makeBloc,
      seed: () => _successSeed().copyWith(
        formError: 'emptyDescription',
        selectedMonth: null,
      ),
      act: (bloc) => bloc
        ..add(const ClearIncomeFormErrorRequested())
        ..add(
          AddIncomeStarted(
            amount: 'x',
            description: 'Salary',
            date: DateTime(DateTime.now().year, 5, 1),
          ),
        ),
      expect: () => [
        isA<IncomeSuccess>().having((s) => s.formError, 'formError', isNull),
        isA<IncomeSuccess>().having(
          (s) => s.formError,
          'formError',
          'invalidAmount',
        ),
      ],
      tearDown: () async => GetIt.instance.reset(),
    );
  });

  // -------------------------------------------------------------------------
  // INC-05: the year/month filter follows a newly added or edited entry.
  // Jump cases use fixed calendar years so they are deterministic year-round;
  // only the no-focus cases (6 and 7) are allowed to read DateTime.now().
  // -------------------------------------------------------------------------

  group('IncomeBloc - INC-05 filter jump', () {
    // Registered/reset at GROUP level, not inside each blocTest: bloc_test runs
    // its own `tearDown` inside the test body, so a failed expectation skips
    // the reset and leaks the StatsBloc registration into the next test as a
    // bogus "already registered" cascade. A group tearDown always runs.
    setUp(() {
      _stubAdd = _StubAddIncomeUseCase();
      _stubUpdate = _StubUpdateIncomeUseCase();
      _stubDelete = _StubDeleteIncomeUseCase();
      _stubGet = _StubGetIncomesUseCase();
      GetIt.instance.registerSingleton<StatsBloc>(FakeStatsBloc());
    });

    tearDown(() async => GetIt.instance.reset());

    final marchEntry = _fakeIncome(id: 'inc-mar', date: DateTime(2026, 3, 15));
    final augustEntry = _fakeIncome(id: 'inc-aug', date: DateTime(2026, 8, 10));
    final priorYearEntry = _fakeIncome(
      id: 'inc-2025',
      date: DateTime(2025, 3, 15),
    );

    IncomeSuccess seed({
      required int selectedYear,
      required List<int> availableYears,
      required List<int> availableMonths,
      required List<Income> incomes,
      int? selectedMonth,
      List<Income>? filtered,
    }) => IncomeSuccess(
      allIncomes: incomes,
      filteredIncomes: filtered ?? incomes,
      selectedYear: selectedYear,
      selectedMonth: selectedMonth,
      availableYears: availableYears,
      availableMonths: availableMonths,
    );

    // Case 1 (D-01)
    blocTest<IncomeBloc, IncomeState>(
      'adding into another month jumps the filter to that month and year',
      setUp: () {
        _stubGet.returnValue = [marchEntry, augustEntry];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: 2026,
        selectedMonth: 8,
        availableYears: const [2026],
        availableMonths: const [3, 8],
        incomes: [marchEntry, augustEntry],
        filtered: [augustEntry],
      ),
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(2026, 3, 15),
        ),
      ),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', 2026)
            .having((s) => s.selectedMonth, 'selectedMonth', 3)
            .having(
              (s) => s.filteredIncomes.map((i) => i.id),
              'filteredIncomes ids',
              contains('inc-mar'),
            ),
      ],
    );

    // Case 2 (D-01) - the jump is unconditional, not "only when hidden".
    blocTest<IncomeBloc, IncomeState>(
      'jumps even when the new entry was already visible',
      setUp: () {
        _stubGet.returnValue = [
          marchEntry,
          _fakeIncome(id: 'inc-mar-2', date: DateTime(2026, 3, 20)),
          augustEntry,
        ];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: 2026,
        selectedMonth: 3,
        availableYears: const [2026],
        availableMonths: const [3, 8],
        incomes: [marchEntry, augustEntry],
        filtered: [marchEntry],
      ),
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(2026, 3, 20),
        ),
      ),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', 2026)
            .having((s) => s.selectedMonth, 'selectedMonth', 3),
      ],
    );

    // Case 3 (D-02)
    blocTest<IncomeBloc, IncomeState>(
      'keeps All months when the entry lands in the selected year',
      setUp: () {
        _stubGet.returnValue = [marchEntry, augustEntry];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: 2026,
        availableYears: const [2026],
        availableMonths: const [8],
        incomes: [augustEntry],
      ),
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(2026, 3, 15),
        ),
      ),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', 2026)
            .having((s) => s.selectedMonth, 'selectedMonth', isNull),
      ],
    );

    // Case 4 (D-02)
    blocTest<IncomeBloc, IncomeState>(
      'moves only the year when All months is active and the year differs',
      setUp: () {
        _stubGet.returnValue = [priorYearEntry, marchEntry, augustEntry];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: 2026,
        availableYears: const [2026, 2025],
        availableMonths: const [3, 8],
        incomes: [marchEntry, augustEntry],
      ),
      act: (bloc) => bloc.add(
        AddIncomeStarted(
          amount: '500.00',
          description: 'Salary',
          date: DateTime(2025, 3, 15),
        ),
      ),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', 2025)
            .having((s) => s.selectedMonth, 'selectedMonth', isNull),
      ],
    );

    // Case 5 (D-03) - editing a date applies the same jump.
    blocTest<IncomeBloc, IncomeState>(
      'editing an entry date jumps the filter to the new month',
      setUp: () {
        _stubGet.returnValue = [
          marchEntry,
          _fakeIncome(id: 'inc-aug', date: DateTime(2026, 3, 15)),
          _fakeIncome(id: 'inc-aug-2', date: DateTime(2026, 8, 20)),
        ];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: 2026,
        selectedMonth: 8,
        availableYears: const [2026],
        availableMonths: const [3, 8],
        incomes: [marchEntry, augustEntry],
        filtered: [augustEntry],
      ),
      act: (bloc) => bloc.add(
        UpdateIncomeStarted(
          _fakeIncome(id: 'inc-aug', date: DateTime(2026, 3, 15)),
        ),
      ),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', 2026)
            .having((s) => s.selectedMonth, 'selectedMonth', 3)
            .having(
              (s) => s.filteredIncomes.map((i) => i.id),
              'filteredIncomes ids',
              contains('inc-aug'),
            ),
      ],
    );

    // Case 6 - delete keeps the now-based reset (no decision covers delete).
    blocTest<IncomeBloc, IncomeState>(
      'deleting still resets the filter to the current-date defaults',
      setUp: () {
        _stubGet.returnValue = [
          _fakeIncome(
            id: 'keep-prior',
            date: DateTime(DateTime.now().year - 1, 3, 15),
          ),
          _fakeIncome(
            id: 'keep-now',
            date: DateTime(DateTime.now().year, DateTime.now().month, 10),
          ),
        ];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: DateTime.now().year - 1,
        selectedMonth: 3,
        availableYears: [DateTime.now().year, DateTime.now().year - 1],
        availableMonths: const [3],
        incomes: [priorYearEntry],
      ),
      act: (bloc) => bloc.add(const DeleteIncomeStarted('inc-1')),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', DateTime.now().year)
            .having(
              (s) => s.selectedMonth,
              'selectedMonth',
              DateTime.now().month,
            ),
      ],
    );

    // Case 7 - a plain reload carries no focus and is unchanged.
    test('a parameterless LoadIncomesRequested carries no focus', () {
      expect(const LoadIncomesRequested().hasFocus, isFalse);
      expect(const LoadIncomesRequested().focusYear, isNull);
      expect(const LoadIncomesRequested().focusMonth, isNull);
    });

    blocTest<IncomeBloc, IncomeState>(
      'a plain reload still selects the current-date defaults',
      setUp: () {
        _stubGet.returnValue = [
          _fakeIncome(
            id: 'keep-prior',
            date: DateTime(DateTime.now().year - 1, 3, 15),
          ),
          _fakeIncome(
            id: 'keep-now',
            date: DateTime(DateTime.now().year, DateTime.now().month, 10),
          ),
        ];
      },
      build: _makeBloc,
      seed: () => seed(
        selectedYear: DateTime.now().year - 1,
        selectedMonth: 3,
        availableYears: [DateTime.now().year, DateTime.now().year - 1],
        availableMonths: const [3],
        incomes: [priorYearEntry],
      ),
      act: (bloc) => bloc.add(const LoadIncomesRequested()),
      expect: () => [
        const IncomeLoading(),
        isA<IncomeSuccess>()
            .having((s) => s.selectedYear, 'selectedYear', DateTime.now().year)
            .having(
              (s) => s.selectedMonth,
              'selectedMonth',
              DateTime.now().month,
            ),
      ],
    );
  });
}
