import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weeklet/domain/entities/income.dart';

part 'income_model.g.dart';

@HiveType(typeId: 2)
class IncomeModel extends Equatable {
  const IncomeModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  factory IncomeModel.fromEntity(Income entity) => IncomeModel(
    id: entity.id,
    amount: entity.amount,
    description: entity.description,
    date: entity.date,
    createdAt: entity.createdAt,
  );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final DateTime createdAt;

  Income toEntity() => Income(
    id: id,
    amount: amount,
    description: description,
    date: date,
    createdAt: createdAt,
  );

  @override
  List<Object> get props => [id, amount, description, date, createdAt];
}
