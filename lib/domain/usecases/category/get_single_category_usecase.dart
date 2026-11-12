import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetSingleCategoryUseCase implements UseCase<Category?, String> {
  GetSingleCategoryUseCase(
    this.repository,
  );

  final CategoryRepository repository;

  @override
  Future<Category?> call(
    String params,
  ) async {
    if (params.trim().isEmpty) {
      throw const CategoryValidationException(
        CategoryValidationError.emptyCategoryId,
      );
    }
    return repository.getCategoryById(
      params,
    );
  }
}
