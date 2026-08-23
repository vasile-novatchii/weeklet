import 'package:weeklet/domain/entities/category.dart';

sealed class CategoryState {
  const CategoryState();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoriesLoaded extends CategoryState {
  const CategoriesLoaded({
    required this.categories,
    this.lastCreatedCategoryId,
  });

  final List<Category> categories;

  /// Id of the category the user created during this session, if any.
  /// The add-expense form consumes it to pre-select a category made mid-flow
  /// (D-10), then clears it so the selection fires exactly once.
  final String? lastCreatedCategoryId;
}

final class CategoryLoaded extends CategoryState {
  const CategoryLoaded({
    required this.category,
  });

  final Category category;
}

final class CategorySuccess extends CategoryState {
  const CategorySuccess({
    required this.message,
  });

  final String message;
}

final class CategoryError extends CategoryState {
  const CategoryError({
    required this.message,
  });

  final String message;
}
