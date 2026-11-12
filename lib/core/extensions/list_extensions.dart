import 'package:weeklet/domain/entities/category.dart';

extension CategoryListExtensions on List<Category> {
  /// Finds a category by its ID
  ///
  /// Returns null if no category with the given ID is found
  Category? findById(String id) {
    try {
      return firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }
}
