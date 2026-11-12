import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/exceptions/income_exceptions.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';

class UpdateIncomeUseCase {
  const UpdateIncomeUseCase(this.repository);

  final IncomeRepository repository;

  Future<void> call(Income params) async {
    if (params.amount <= 0) {
      throw const IncomeValidationException(
        IncomeValidationError.invalidAmount,
      );
    }
    await repository.updateIncome(params);
  }
}
