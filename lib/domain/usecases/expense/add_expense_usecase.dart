import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/exceptions/expense_exceptions.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class AddExpenseParams {
  const AddExpenseParams({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
  });

  final String amount;
  final String description;
  final String categoryId;
  final DateTime date;
}

class AddExpenseUseCase implements UseCase<void, AddExpenseParams> {
  const AddExpenseUseCase(this.repository, this.uuid);

  final ExpenseRepository repository;
  final Uuid uuid;

  @override
  Future<void> call(AddExpenseParams params) async {
    final expense = _buildAndValidate(params);
    return repository.addExpense(expense);
  }

  Expense _buildAndValidate(AddExpenseParams params) {
    final parsedAmount = double.tryParse(params.amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      throw const ExpenseValidationException(
        ExpenseValidationError.invalidAmount,
      );
    }
    if (params.categoryId.trim().isEmpty) {
      throw const ExpenseValidationException(
        ExpenseValidationError.emptyCategory,
      );
    }
    final now = DateTime.now();
    return Expense(
      id: uuid.v4(),
      amount: parsedAmount,
      description: params.description.trim(),
      categoryId: params.categoryId,
      createdAt: DateTime(
        params.date.year,
        params.date.month,
        params.date.day,
        now.hour,
        now.minute,
        now.second,
      ),
    );
  }
}
