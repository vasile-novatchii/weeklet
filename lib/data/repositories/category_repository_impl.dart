import 'package:flutter/foundation.dart' show debugPrint;
import 'package:weeklet/data/datasources/local/category_local_datasource.dart';
import 'package:weeklet/data/models/category_model.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this.localDataSource);

  final CategoryLocalDataSource localDataSource;

  @override
  Future<void> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.addCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) => localDataSource.deleteCategory(id);

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.updateCategory(model);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final models = await localDataSource.getAllCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final model = await localDataSource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<void> clearAll() async {
    try {
      await localDataSource.clearAll();
    } catch (e) {
      debugPrint('[CategoryRepositoryImpl.clearAll] error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getDefaultCategoryId() =>
      localDataSource.getDefaultCategoryId();

  @override
  Future<void> setDefaultCategoryId(String id) =>
      localDataSource.setDefaultCategoryId(id);
}
