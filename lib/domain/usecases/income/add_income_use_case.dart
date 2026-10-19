import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/exceptions/income_exceptions.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class AddIncomeParams {
  const AddIncomeParams({
    required this.amount,
    required this.description,
    required this.date,
  });

  final String amount;
  final String description;
  final DateTime date;
}

class AddIncomeUseCase implements UseCase<void, AddIncomeParams> {
  const AddIncomeUseCase(this.repository, this.uuid);

  final IncomeRepository repository;
  final Uuid uuid;

  @override
  Future<void> call(AddIncomeParams params) async {
    final income = _buildAndValidate(params);
    await repository.addIncome(income);
  }

  Income _buildAndValidate(AddIncomeParams params) {
    final parsedAmount = double.tryParse(params.amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      throw const IncomeValidationException(
        IncomeValidationError.invalidAmount,
      );
    }
    final now = DateTime.now();
    return Income(
      id: uuid.v4(),
      amount: parsedAmount,
      description: params.description.trim(),
      date: params.date,
      createdAt: now,
    );
  }
}
