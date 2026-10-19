import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/get_or_create_default_category_usecase.dart';

class EnsureDefaultCategoryParams {
  const EnsureDefaultCategoryParams({required this.localizedName});

  /// The default category name in the active app language.
  final String localizedName;
}

/// Seeds the app-managed default category, but only when no category exists
/// at all (first launch, or the user deleted every category). Existing
/// installs with categories are never modified.
///
/// Returns the created category, or null when nothing was seeded.
class EnsureDefaultCategoryUseCase
    implements UseCase<Category?, EnsureDefaultCategoryParams> {
  const EnsureDefaultCategoryUseCase(
    this.repository,
    this.getOrCreateDefaultCategory,
  );

  final CategoryRepository repository;
  final GetOrCreateDefaultCategoryUseCase getOrCreateDefaultCategory;

  @override
  Future<Category?> call(EnsureDefaultCategoryParams params) async {
    final existing = await repository.getAllCategories();
    if (existing.isNotEmpty) return null;
    return getOrCreateDefaultCategory(
      GetOrCreateDefaultCategoryParams(localizedName: params.localizedName),
    );
  }
}
