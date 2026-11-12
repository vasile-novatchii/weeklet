import 'package:equatable/equatable.dart';

class Income extends Equatable {
  const Income({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  @override
  List<Object> get props => [id, amount, description, date, createdAt];
}
