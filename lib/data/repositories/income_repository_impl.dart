import 'package:flutter/foundation.dart' show debugPrint;
import 'package:weeklet/data/datasources/local/income_local_data_source.dart';
import 'package:weeklet/data/models/income_model.dart';
import 'package:weeklet/domain/entities/income.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  const IncomeRepositoryImpl(this.localDataSource);

  final IncomeLocalDataSource localDataSource;

  @override
  Future<void> addIncome(Income income) async {
    final model = IncomeModel.fromEntity(income);
    await localDataSource.addIncome(model);
  }

  @override
  Future<void> updateIncome(Income income) async {
    final model = IncomeModel.fromEntity(income);
    await localDataSource.updateIncome(model);
  }

  @override
  Future<void> deleteIncome(String id) async {
    await localDataSource.deleteIncome(id);
  }

  @override
  Future<List<Income>> getIncomes() async {
    final models = await localDataSource.getIncomes();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> clearAll() async {
    try {
      await localDataSource.clearAll();
    } catch (e) {
      debugPrint('[IncomeRepositoryImpl.clearAll] error: $e');
      rethrow;
    }
  }
}
