// Fake BLoC classes for GetIt registration in Wave 2+3 tests.
// These absorb .add() calls without crashing and expose their initial state.
// All classes are public so they can be imported across test files.
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/entities/statistics.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_or_create_default_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_single_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/update_category_usecase.dart';
import 'package:weeklet/domain/usecases/expense/add_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/delete_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/get_all_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/expense/update_expense_usecase.dart';
import 'package:weeklet/domain/usecases/income/add_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/delete_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/get_incomes_use_case.dart';
import 'package:weeklet/domain/usecases/income/update_income_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_available_periods_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_evolution_stats_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_monthly_stats_use_case.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';

// ---------------------------------------------------------------------------
// Stub use cases for FakeStatsBloc
// ---------------------------------------------------------------------------

// These stubs use noSuchMethod so the concrete use case's `repository` field
// (which becomes part of the abstract contract) is implicitly satisfied.

class _StubGetMonthlyStatsUseCase implements GetMonthlyStatsUseCase {
  @override
  Future<MonthlyStats> call(GetMonthlyStatsParams params) async =>
      const MonthlyStats(
        totalIncome: 0,
        totalExpenses: 0,
        balance: 0,
        incomeGrowthPercentage: 0,
        expenseGrowthPercentage: 0,
        categoryStats: [],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetEvolutionStatsUseCase implements GetEvolutionStatsUseCase {
  @override
  Future<EvolutionStats> call(GetEvolutionStatsParams params) async =>
      const EvolutionStats(snapshots: []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetAvailablePeriodsUseCase implements GetAvailablePeriodsUseCase {
  @override
  Future<Map<int, List<int>>> call(NoParams params) async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// FakeStatsBloc — extends StatsBloc so it can be registered as StatsBloc
// ---------------------------------------------------------------------------

class FakeStatsBloc extends StatsBloc {
  FakeStatsBloc()
    : super(
        getMonthlyStatsUseCase: _StubGetMonthlyStatsUseCase(),
        getEvolutionStatsUseCase: _StubGetEvolutionStatsUseCase(),
        getAvailablePeriodsUseCase: _StubGetAvailablePeriodsUseCase(),
      );
}

// ---------------------------------------------------------------------------
// Stub use cases for FakeExpenseBloc
// ---------------------------------------------------------------------------

class _StubAddExpenseUseCase implements AddExpenseUseCase {
  @override
  Future<void> call(AddExpenseParams params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubUpdateExpenseUseCase implements UpdateExpenseUseCase {
  @override
  Future<void> call(Expense params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubDeleteExpenseUseCase implements DeleteExpenseUseCase {
  @override
  Future<void> call(String params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetAllExpensesUseCase implements GetAllExpensesUseCase {
  @override
  Future<List<Expense>> call(NoParams params) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetOrCreateDefaultCategoryUseCase
    implements GetOrCreateDefaultCategoryUseCase {
  @override
  Future<Category> call(GetOrCreateDefaultCategoryParams params) async =>
      Category(
        id: 'stub-default-category',
        name: params.localizedName,
        icon: 'home',
        createdAt: DateTime(2025),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Stub use cases for FakeIncomeBloc
// ---------------------------------------------------------------------------

class _StubAddIncomeUseCase implements AddIncomeUseCase {
  @override
  Future<void> call(AddIncomeParams params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubUpdateIncomeUseCase implements UpdateIncomeUseCase {
  @override
  Future<void> call(Income params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubDeleteIncomeUseCase implements DeleteIncomeUseCase {
  @override
  Future<void> call(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetIncomesUseCase implements GetIncomesUseCase {
  @override
  Future<List<Income>> call() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Stub use cases for FakeCategoryBloc
// ---------------------------------------------------------------------------

class _StubAddCategoryUseCase implements AddCategoryUseCase {
  @override
  Future<void> call(AddCategoryParams params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubUpdateCategoryUseCase implements UpdateCategoryUseCase {
  @override
  Future<void> call(Category params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubDeleteCategoryUseCase implements DeleteCategoryUseCase {
  @override
  Future<void> call(String params) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetAllCategoriesUseCase implements GetAllCategoriesUseCase {
  @override
  Future<List<Category>> call(NoParams params) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGetSingleCategoryUseCase implements GetSingleCategoryUseCase {
  @override
  Future<Category?> call(String params) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// FakeExpenseBloc — extends ExpenseBloc so it can be registered as ExpenseBloc
// ---------------------------------------------------------------------------

class FakeExpenseBloc extends ExpenseBloc {
  FakeExpenseBloc()
    : super(
        addExpenseUseCase: _StubAddExpenseUseCase(),
        updateExpenseUseCase: _StubUpdateExpenseUseCase(),
        deleteExpenseUseCase: _StubDeleteExpenseUseCase(),
        getExpensesUseCase: _StubGetAllExpensesUseCase(),
        getOrCreateDefaultCategoryUseCase:
            _StubGetOrCreateDefaultCategoryUseCase(),
      );
}

// ---------------------------------------------------------------------------
// FakeIncomeBloc — extends IncomeBloc so it can be registered as IncomeBloc
// ---------------------------------------------------------------------------

class FakeIncomeBloc extends IncomeBloc {
  FakeIncomeBloc()
    : super(
        addIncomeUseCase: _StubAddIncomeUseCase(),
        updateIncomeUseCase: _StubUpdateIncomeUseCase(),
        deleteIncomeUseCase: _StubDeleteIncomeUseCase(),
        getIncomesUseCase: _StubGetIncomesUseCase(),
      );
}

// ---------------------------------------------------------------------------
// FakeCategoryBloc — extends CategoryBloc so it can be registered as CategoryBloc
// ---------------------------------------------------------------------------

class FakeCategoryBloc extends CategoryBloc {
  FakeCategoryBloc()
    : super(
        addCategoryUseCase: _StubAddCategoryUseCase(),
        updateCategoryUseCase: _StubUpdateCategoryUseCase(),
        deleteCategoryUseCase: _StubDeleteCategoryUseCase(),
        getAllCategoriesUseCase: _StubGetAllCategoriesUseCase(),
        getCategoryByIdUseCase: _StubGetSingleCategoryUseCase(),
      );
}
