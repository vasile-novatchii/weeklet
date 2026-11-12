import 'package:weeklet/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<void> addCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(Category category);
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> clearAll();

  /// Reads the id of the app-managed default ("no category selected")
  /// category, or null when no default has been resolved yet.
  Future<String?> getDefaultCategoryId();

  /// Stores [id] as the app-managed default category marker.
  Future<void> setDefaultCategoryId(String id);
}
