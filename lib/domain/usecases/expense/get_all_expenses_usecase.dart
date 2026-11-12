import 'package:weeklet/domain/entities/expense.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetAllExpensesUseCase implements UseCase<List<Expense>, NoParams> {
  const GetAllExpensesUseCase(this.repository);

  final ExpenseRepository repository;

  @override
  Future<List<Expense>> call(NoParams params) => repository.getAllExpenses();
}
