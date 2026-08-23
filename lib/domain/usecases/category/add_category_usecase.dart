import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class AddCategoryParams {
  const AddCategoryParams({
    required this.name,
    required this.icon,
    required this.createdAt,
  });

  final String name;
  final String icon;
  final DateTime createdAt;
}

/// Creates a user-facing category and returns the persisted entity, so that
/// callers learn the generated uuid without re-finding the record by name.
/// Names are user-editable data and must never be used as identity (D-09).
class AddCategoryUseCase implements UseCase<Category, AddCategoryParams> {
  AddCategoryUseCase(this.repository, this.uuid);

  final CategoryRepository repository;
  final Uuid uuid;

  @override
  Future<Category> call(AddCategoryParams params) async {
    if (params.name.trim().isEmpty) {
      throw const CategoryValidationException(
        CategoryValidationError.emptyName,
      );
    }
    if (params.icon.trim().isEmpty) {
      throw const CategoryValidationException(
        CategoryValidationError.emptyIcon,
      );
    }
    final existing = await repository.getAllCategories();
    final normalizedNew = params.name.trim().toLowerCase();
    if (existing.any((c) => c.name.trim().toLowerCase() == normalizedNew)) {
      throw const CategoryValidationException(
        CategoryValidationError.duplicateName,
      );
    }
    final category = Category(
      id: uuid.v4(),
      name: params.name,
      icon: params.icon,
      createdAt: params.createdAt,
    );
    await repository.addCategory(category);
    return category;
  }
}
