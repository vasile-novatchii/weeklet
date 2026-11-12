import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weeklet/domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends Equatable {
  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.createdAt,
  });

  factory ExpenseModel.fromEntity(Expense entity) => ExpenseModel(
    id: entity.id,
    amount: entity.amount,
    createdAt: entity.createdAt,
    categoryId: entity.categoryId,
    description: entity.description,
  );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final DateTime createdAt;

  Expense toEntity() => Expense(
    id: id,
    categoryId: categoryId,
    createdAt: createdAt,
    amount: amount,
    description: description,
  );

  @override
  List<Object> get props => [id, amount, description, categoryId, createdAt];

  @override
  String toString() =>
      'ExpenseModel{id: $id, amount: $amount, description: $description, categoryId: $categoryId, createdAt: $createdAt}';
}
