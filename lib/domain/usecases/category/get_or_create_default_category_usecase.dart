import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';

class GetOrCreateDefaultCategoryParams {
  const GetOrCreateDefaultCategoryParams({required this.localizedName});

  /// The default category name in the active app language, resolved by the
  /// presentation layer (EN "Daily" / RO "Zilnic" / RU "Ежедневно", D-09).
  /// It arrives as data so the domain layer stays Flutter-free.
  final String localizedName;
}

/// Resolves the app-managed default ("no category selected") category,
/// creating it only when it genuinely does not exist yet.
///
/// CAT-01 / D-08 / D-11: this replaces the widget-side fallback that matched
/// the literal name 'daily' case-insensitively, which let a user-created
/// category named "Daily" silently receive fallback expenses. Identity is now
/// the stored `default_category_id` marker, so the default survives a rename
/// and a user category can never be adopted by naming it "Daily".
///
/// Creation deliberately calls [CategoryRepository.addCategory] directly
/// instead of routing through `AddCategoryUseCase`. That use case's
/// duplicate-name guard is a user-facing rule only; routing the fallback
/// through it re-creates the defect where an uncaught
/// `CategoryValidationError.duplicateName` aborted the expense save.
class GetOrCreateDefaultCategoryUseCase
    implements UseCase<Category, GetOrCreateDefaultCategoryParams> {
  GetOrCreateDefaultCategoryUseCase(this.repository, this.uuid);

  final CategoryRepository repository;
  final Uuid uuid;

  /// Localized names the old widget flow could have auto-created. Used once,
  /// only when no marker exists, so an existing default is adopted rather
  /// than duplicated. Immediately replaced by an id marker, so this closed
  /// set can never match twice on the same database.
  static const Set<String> knownDefaultNames = {
    'daily',
    'zilnic',
    'ежедневно',
  };

  /// Icon assigned to a freshly created default category.
  static const String defaultIcon = 'home';

  @override
  Future<Category> call(GetOrCreateDefaultCategoryParams params) async {
    final trimmedName = params.localizedName.trim();
    if (trimmedName.isEmpty) {
      throw const CategoryValidationException(
        CategoryValidationError.emptyName,
      );
    }

    // 1. Marker path — the authoritative, rename-proof identity.
    final markedId = await repository.getDefaultCategoryId();
    if (markedId != null) {
      final marked = await repository.getCategoryById(markedId);
      if (marked != null) return marked;
      // A dangling marker (category deleted) falls through rather than
      // throwing, and gets rewritten below.
    }

    // 2. One-time legacy adoption. `getAllCategories` returns ascending by
    // `createdAt`, so the first match is the oldest one.
    final existing = await repository.getAllCategories();
    for (final category in existing) {
      if (knownDefaultNames.contains(category.name.trim().toLowerCase())) {
        await repository.setDefaultCategoryId(category.id);
        return category;
      }
    }

    // 3. Creation — bypasses the user-facing duplicate-name guard by design.
    final created = Category(
      id: uuid.v4(),
      name: params.localizedName,
      icon: defaultIcon,
      createdAt: DateTime.now(),
    );
    await repository.addCategory(created);
    await repository.setDefaultCategoryId(created.id);
    return created;
  }
}
