import 'package:weeklet/domain/entities/category.dart';

/// Rule for pre-selecting the default category in a new expense form.
abstract final class DefaultCategorySelection {
  /// Returns [defaultCategoryId] only when the default is the sole category.
  /// Otherwise null, so the form starts empty ("Select Category").
  static String? preselectedCategoryId(
    List<Category> categories,
    String? defaultCategoryId,
  ) {
    if (defaultCategoryId == null || categories.length != 1) return null;
    return categories.first.id == defaultCategoryId ? defaultCategoryId : null;
  }
}
