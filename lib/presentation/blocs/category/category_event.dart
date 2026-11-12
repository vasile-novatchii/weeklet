sealed class CategoryEvent {
  const CategoryEvent();
}

final class AddCategoryEvent extends CategoryEvent {
  const AddCategoryEvent({
    required this.name,
    required this.icon,
  });

  final String name;
  final String icon;
}

final class UpdateCategoryEvent extends CategoryEvent {
  const UpdateCategoryEvent({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String icon;
  final DateTime createdAt;
}

final class DeleteCategoryEvent extends CategoryEvent {
  const DeleteCategoryEvent({
    required this.id,
  });

  final String id;
}

final class GetAllCategoriesEvent extends CategoryEvent {
  const GetAllCategoriesEvent();
}

/// Dispatched once at startup. Seeds the default category (named
/// [localizedName]) only when no category exists, then loads all categories.
final class EnsureDefaultCategoryRequested extends CategoryEvent {
  const EnsureDefaultCategoryRequested({required this.localizedName});

  final String localizedName;
}

/// Dispatched by the add-expense form once it has consumed the auto-select of
/// a category created mid-flow, so the selection fires exactly once per
/// creation and a later reload cannot re-apply it.
final class ClearLastCreatedCategoryRequested extends CategoryEvent {
  const ClearLastCreatedCategoryRequested();
}

final class GetCategoryByIdEvent extends CategoryEvent {
  const GetCategoryByIdEvent({
    required this.id,
  });

  final String id;
}
