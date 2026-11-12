import 'package:weeklet/domain/exceptions/expense_exceptions.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class DeleteExpenseUseCase implements UseCase<void, String> {
  const DeleteExpenseUseCase(this.repository);

  final ExpenseRepository repository;

  @override
  Future<void> call(String params) async {
    if (params.isEmpty) {
      throw const ExpenseValidationException(
        ExpenseValidationError.emptyExpenseId,
      );
    }
    await repository.deleteExpense(params);
  }
}
