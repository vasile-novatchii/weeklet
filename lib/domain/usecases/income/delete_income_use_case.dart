import 'package:weeklet/domain/repositories/income_repository.dart';

class DeleteIncomeUseCase {
  const DeleteIncomeUseCase(this.repository);

  final IncomeRepository repository;

  Future<void> call(String id) => repository.deleteIncome(id);
}
