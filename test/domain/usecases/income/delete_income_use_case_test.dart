import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/usecases/income/delete_income_use_case.dart';

// Minimal in-memory stub — no Hive, no DI
class _StubIncomeRepository implements IncomeRepository {
  String? lastDeletedId;

  @override
  Future<void> deleteIncome(String id) async => lastDeletedId = id;

  @override
  Future<void> addIncome(Income income) async {}

  @override
  Future<void> updateIncome(Income income) async {}

  @override
  Future<List<Income>> getIncomes() async => [];

  @override
  Future<void> clearAll() async {}
}

void main() {
  late _StubIncomeRepository repository;
  late DeleteIncomeUseCase useCase;

  setUp(() {
    repository = _StubIncomeRepository();
    useCase = DeleteIncomeUseCase(repository);
  });

  group('DeleteIncomeUseCase — delegation', () {
    test(
      'delegates to repository without throwing for any id',
      () async {
        await expectLater(useCase('income-456'), completes);
        expect(repository.lastDeletedId, 'income-456');
      },
    );
  });
}
