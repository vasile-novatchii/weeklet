import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weeklet/data/models/income_model.dart';

abstract class IncomeLocalDataSource {
  Future<void> addIncome(IncomeModel income);
  Future<void> updateIncome(IncomeModel income);
  Future<void> deleteIncome(String id);
  Future<List<IncomeModel>> getIncomes();
  Future<void> clearAll();
}

class IncomeLocalDataSourceImpl implements IncomeLocalDataSource {
  IncomeLocalDataSourceImpl(this.incomeBox);

  final Box<IncomeModel> incomeBox;

  @override
  Future<void> addIncome(IncomeModel income) async {
    try {
      await incomeBox.put(income.id, income);
    } catch (e) {
      debugPrint('[IncomeLocalDataSourceImpl.addIncome] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateIncome(IncomeModel income) async {
    try {
      await incomeBox.put(income.id, income);
    } catch (e) {
      debugPrint('[IncomeLocalDataSourceImpl.updateIncome] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteIncome(String id) async {
    try {
      await incomeBox.delete(id);
    } catch (e) {
      debugPrint('[IncomeLocalDataSourceImpl.deleteIncome] error: $e');
      rethrow;
    }
  }

  @override
  Future<List<IncomeModel>> getIncomes() async {
    try {
      return incomeBox.values.toList();
    } catch (e) {
      debugPrint('[IncomeLocalDataSourceImpl.getIncomes] error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await incomeBox.clear();
    } catch (e) {
      debugPrint('[IncomeLocalDataSourceImpl.clearAll] error: $e');
      rethrow;
    }
  }
}
