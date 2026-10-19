import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

/// Returns the id of the app-managed default category, or null when the
/// marker is unset or points at a category that no longer exists.
class GetDefaultCategoryIdUseCase implements UseCase<String?, NoParams> {
  const GetDefaultCategoryIdUseCase(this.repository);

  final CategoryRepository repository;

  @override
  Future<String?> call(NoParams params) async {
    final id = await repository.getDefaultCategoryId();
    if (id == null) return null;
    final category = await repository.getCategoryById(id);
    return category == null ? null : id;
  }
}
