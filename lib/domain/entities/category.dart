import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String icon;
  final DateTime createdAt;

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  String toString() =>
      'Category{id: $id, name: $name, icon: $icon, createdAt: $createdAt}';

  @override
  List<Object> get props => [id, name, icon, createdAt];
}
