import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/exceptions/expense_exceptions.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/usecases/expense/delete_expense_usecase.dart';

// Minimal in-memory stub — no Hive, no DI
class _StubExpenseRepository implements ExpenseRepository {
  String? lastDeletedId;

  @override
  Future<void> deleteExpense(String id) async => lastDeletedId = id;

  @override
  Future<List<Expense>> getAllExpenses() async => [];

  @override
  Future<List<Expense>> getExpensesByMonthYear(int month, int year) async => [];

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> clearAll() async {}
}

void main() {
  late _StubExpenseRepository repository;
  late DeleteExpenseUseCase useCase;

  setUp(() {
    repository = _StubExpenseRepository();
    useCase = DeleteExpenseUseCase(repository);
  });

  group('DeleteExpenseUseCase — validation', () {
    test(
      'throws ExpenseValidationException(emptyExpenseId) for empty id',
      () {
        expect(
          () async => useCase(''),
          throwsA(
            isA<ExpenseValidationException>().having(
              (e) => e.error,
              'error',
              ExpenseValidationError.emptyExpenseId,
            ),
          ),
        );
      },
    );

    test(
      'delegates to repository for valid id without throwing',
      () async {
        await expectLater(useCase('expense-123'), completes);
        expect(repository.lastDeletedId, 'expense-123');
      },
    );
  });
}
