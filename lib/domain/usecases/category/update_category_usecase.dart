import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class UpdateCategoryUseCase implements UseCase<void, Category> {
  UpdateCategoryUseCase(
    this.repository,
  );
  final CategoryRepository repository;

  @override
  Future<void> call(
    Category params,
  ) async {
    if (params.id.trim().isEmpty) {
      throw const CategoryValidationException(
        CategoryValidationError.emptyId,
      );
    }
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
    return repository.updateCategory(
      params,
    );
  }
}
