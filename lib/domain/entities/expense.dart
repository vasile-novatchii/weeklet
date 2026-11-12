import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime createdAt;

  @override
  List<Object> get props => [
    id,
    categoryId,
    amount,
    createdAt,
    description,
  ];

  @override
  String toString() =>
      'Expense{id: $id, categoryId: $categoryId, amount: $amount, createdAt: $createdAt, description: $description}';
}
