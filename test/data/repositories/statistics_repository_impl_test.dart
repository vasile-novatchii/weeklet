import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/data/repositories/statistics_repository_impl.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';

// ---------------------------------------------------------------------------
// Fake repositories — plain Dart stubs, no Mockito
// ---------------------------------------------------------------------------

class _FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<List<Expense>> getExpensesByMonthYear(int month, int year) async => [];

  @override
  Future<List<Expense>> getAllExpenses() async => [];

  @override
  Future<void> clearAll() async {}
}

class _FakeIncomeRepository implements IncomeRepository {
  int getIncomesCallCount = 0;

  @override
  Future<void> addIncome(Income income) async {}

  @override
  Future<List<Income>> getIncomes() async {
    getIncomesCallCount++;
    return [];
  }

  @override
  Future<void> updateIncome(Income income) async {}

  @override
  Future<void> deleteIncome(String id) async {}

  @override
  Future<void> clearAll() async {}
}

class _FakeCategoryRepository implements CategoryRepository {
  int getAllCategoriesCallCount = 0;

  @override
  Future<void> addCategory(Category category) async {}

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<List<Category>> getAllCategories() async {
    getAllCategoriesCallCount++;
    return [];
  }

  @override
  Future<Category?> getCategoryById(String id) async => null;

  @override
  Future<void> clearAll() async {}

  @override
  Future<String?> getDefaultCategoryId() async => null;

  @override
  Future<void> setDefaultCategoryId(String id) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeExpenseRepository expenseRepo;
  late _FakeIncomeRepository incomeRepo;
  late _FakeCategoryRepository categoryRepo;
  late StatisticsRepositoryImpl sut;

  setUp(() {
    expenseRepo = _FakeExpenseRepository();
    incomeRepo = _FakeIncomeRepository();
    categoryRepo = _FakeCategoryRepository();
    sut = StatisticsRepositoryImpl(
      expenseRepository: expenseRepo,
      incomeRepository: incomeRepo,
      categoryRepository: categoryRepo,
    );
  });

  group('StatisticsRepositoryImpl.getEvolutionStats (STAT-03, STAT-04)', () {
    test(
      'Test 1: returns exactly 12 MonthlySnapshots for a given year',
      () async {
        final result = await sut.getEvolutionStats(2024);

        expect(result.snapshots, hasLength(12));
      },
    );

    test(
      'Test 2: each snapshot.month is in range 1–12 with no duplicates '
      '(months 1 through 12 all present)',
      () async {
        final result = await sut.getEvolutionStats(2024);

        final months = result.snapshots.map((s) => s.month).toList();
        expect(months, containsAll([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]));
        expect(months.toSet().length, equals(12));
        for (final m in months) {
          expect(m, inInclusiveRange(1, 12));
        }
      },
    );

    test(
      'Test 3: snapshot.year equals the requested year for all 12 snapshots',
      () async {
        const requestedYear = 2024;
        final result = await sut.getEvolutionStats(requestedYear);

        for (final snapshot in result.snapshots) {
          expect(snapshot.year, equals(requestedYear));
        }
      },
    );

    test(
      'Test 4: getIncomes() is called exactly once '
      '(not once per month — STAT-04)',
      () async {
        await sut.getEvolutionStats(2024);

        expect(incomeRepo.getIncomesCallCount, equals(1));
      },
    );

    test(
      'Test 5: getAllCategories() is called exactly once '
      '(not once per month — STAT-04)',
      () async {
        await sut.getEvolutionStats(2024);

        expect(categoryRepo.getAllCategoriesCallCount, equals(1));
      },
    );
  });
}
