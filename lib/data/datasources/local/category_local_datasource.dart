import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weeklet/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<void> addCategory(CategoryModel model);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(CategoryModel model);
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> clearAll();

  /// Reads the id of the app-managed default ("no category selected")
  /// category, or null when no default has been resolved yet.
  Future<String?> getDefaultCategoryId();

  /// Stores [id] as the app-managed default category marker.
  Future<void> setDefaultCategoryId(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this.categoryBox, this.settingsBox);

  final Box<CategoryModel> categoryBox;

  /// Shared settings box. The default-category marker is a primitive
  /// `String` id, so it lives here rather than in a `CategoryModel`
  /// `@HiveField` - `hive_generator` is disabled in `pubspec.yaml`
  /// (analyzer conflict with `bloc_test`), so the generated adapter
  /// cannot be regenerated and must never be hand-edited.
  final Box<dynamic> settingsBox;

  static const String _defaultCategoryIdKey = 'default_category_id';

  @override
  Future<void> addCategory(CategoryModel model) async =>
      categoryBox.put(model.id, model);

  @override
  Future<void> deleteCategory(String id) async => categoryBox.delete(id);

  @override
  Future<void> updateCategory(CategoryModel model) async =>
      categoryBox.put(model.id, model);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final List<CategoryModel> list = categoryBox.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async =>
      categoryBox.get(id);

  @override
  Future<void> clearAll() async {
    try {
      await categoryBox.clear();
    } catch (e) {
      debugPrint('[CategoryLocalDataSourceImpl.clearAll] error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getDefaultCategoryId() async {
    try {
      return settingsBox.get(_defaultCategoryIdKey) as String?;
    } catch (e) {
      debugPrint(
        '[CategoryLocalDataSourceImpl.getDefaultCategoryId] error: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> setDefaultCategoryId(String id) async {
    try {
      await settingsBox.put(_defaultCategoryIdKey, id);
    } catch (e) {
      debugPrint(
        '[CategoryLocalDataSourceImpl.setDefaultCategoryId] error: $e',
      );
      rethrow;
    }
  }
}
