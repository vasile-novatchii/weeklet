import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/exceptions/expense_exceptions.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/usecases/expense/update_expense_usecase.dart';

class _StubExpenseRepository implements ExpenseRepository {
  Expense? lastUpdated;

  @override
  Future<void> updateExpense(Expense expense) async => lastUpdated = expense;

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<List<Expense>> getAllExpenses() async => [];

  @override
  Future<List<Expense>> getExpensesByMonthYear(int month, int year) async => [];

  @override
  Future<void> clearAll() async {}
}

Expense _expense({
  String description = '',
  double amount = 10,
  String categoryId = 'cat-1',
}) => Expense(
  id: 'e1',
  amount: amount,
  description: description,
  categoryId: categoryId,
  createdAt: DateTime(2024, 1, 15),
);

void main() {
  late _StubExpenseRepository repository;
  late UpdateExpenseUseCase useCase;

  setUp(() {
    repository = _StubExpenseRepository();
    useCase = UpdateExpenseUseCase(repository);
  });

  test('accepts an expense with empty description', () async {
    await useCase(_expense());
    expect(repository.lastUpdated?.description, '');
  });

  test('still rejects amount <= 0', () {
    expect(
      () async => useCase(_expense(amount: 0)),
      throwsA(
        isA<ExpenseValidationException>().having(
          (e) => e.error,
          'error',
          ExpenseValidationError.invalidAmount,
        ),
      ),
    );
  });

  test('still rejects empty categoryId', () {
    expect(
      () async => useCase(_expense(categoryId: ' ')),
      throwsA(
        isA<ExpenseValidationException>().having(
          (e) => e.error,
          'error',
          ExpenseValidationError.emptyCategory,
        ),
      ),
    );
  });
}
