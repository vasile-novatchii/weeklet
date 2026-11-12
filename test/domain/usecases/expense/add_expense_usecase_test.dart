import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/exceptions/expense_exceptions.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/usecases/expense/add_expense_usecase.dart';

// Minimal in-memory stub — no Hive, no DI
class _StubExpenseRepository implements ExpenseRepository {
  Expense? lastAdded;

  @override
  Future<void> addExpense(Expense expense) async => lastAdded = expense;

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<List<Expense>> getAllExpenses() async => [];

  @override
  Future<List<Expense>> getExpensesByMonthYear(int month, int year) async => [];

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> clearAll() async {}
}

void main() {
  late _StubExpenseRepository repository;
  late AddExpenseUseCase useCase;

  setUp(() {
    repository = _StubExpenseRepository();
    useCase = AddExpenseUseCase(repository, const Uuid());
  });

  group('AddExpenseUseCase — amount validation (ARCH-01)', () {
    test(
      'throws ExpenseValidationException(invalidAmount) for non-numeric amount',
      () {
        expect(
          () async => useCase(
            AddExpenseParams(
              amount: 'abc',
              description: 'Test expense',
              categoryId: 'cat-1',
              date: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<ExpenseValidationException>().having(
              (e) => e.error,
              'error',
              ExpenseValidationError.invalidAmount,
            ),
          ),
        );
      },
    );

    test(
      'throws ExpenseValidationException(invalidAmount) for zero amount',
      () {
        expect(
          () async => useCase(
            AddExpenseParams(
              amount: '0',
              description: 'Test expense',
              categoryId: 'cat-1',
              date: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<ExpenseValidationException>().having(
              (e) => e.error,
              'error',
              ExpenseValidationError.invalidAmount,
            ),
          ),
        );
      },
    );

    test(
      'throws ExpenseValidationException(invalidAmount) for negative amount',
      () {
        expect(
          () async => useCase(
            AddExpenseParams(
              amount: '-5.0',
              description: 'Test expense',
              categoryId: 'cat-1',
              date: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<ExpenseValidationException>().having(
              (e) => e.error,
              'error',
              ExpenseValidationError.invalidAmount,
            ),
          ),
        );
      },
    );

    test(
      'accepts empty or whitespace description and stores trimmed',
      () async {
        for (final d in ['', '   ']) {
          await useCase(
            AddExpenseParams(
              amount: '100.50',
              description: d,
              categoryId: 'cat-1',
              date: DateTime(2024, 1, 15),
            ),
          );
          expect(repository.lastAdded?.description, '');
        }
      },
    );

    test(
      'throws ExpenseValidationException(emptyCategory) for empty categoryId',
      () {
        expect(
          () async => useCase(
            AddExpenseParams(
              amount: '100.50',
              description: 'Test expense',
              categoryId: '',
              date: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<ExpenseValidationException>().having(
              (e) => e.error,
              'error',
              ExpenseValidationError.emptyCategory,
            ),
          ),
        );
      },
    );

    test('succeeds for valid params', () async {
      await expectLater(
        useCase(
          AddExpenseParams(
            amount: '100.50',
            description: 'Test expense',
            categoryId: 'cat-1',
            date: DateTime(2024, 1, 15),
          ),
        ),
        completes,
      );
    });
  });

  group('AddExpenseUseCase — UUID generation (ARCH-02)', () {
    test('generated expense has non-empty id', () async {
      await useCase(
        AddExpenseParams(
          amount: '100.50',
          description: 'Test expense',
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
        ),
      );
      expect(repository.lastAdded, isNotNull);
      expect(repository.lastAdded!.id, isNotEmpty);
    });
  });
}
