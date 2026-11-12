import 'package:weeklet/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(Expense expense);
  Future<List<Expense>> getExpensesByMonthYear(int month, int year);
  Future<List<Expense>> getAllExpenses();
  Future<void> clearAll();
}
