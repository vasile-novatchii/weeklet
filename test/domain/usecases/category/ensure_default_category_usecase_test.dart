import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/ensure_default_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_default_category_id_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_or_create_default_category_usecase.dart';

class _StubRepo implements CategoryRepository {
  String? marker;
  final List<Category> stored = [];

  @override
  Future<void> addCategory(Category category) async => stored.add(category);

  @override
  Future<List<Category>> getAllCategories() async => List.of(stored);

  @override
  Future<Category?> getCategoryById(String id) async {
    for (final c in stored) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<String?> getDefaultCategoryId() async => marker;

  @override
  Future<void> setDefaultCategoryId(String id) async => marker = id;
}

Category _cat(String id, String name) =>
    Category(id: id, name: name, icon: 'home', createdAt: DateTime(2024));

void main() {
  late _StubRepo repo;
  late EnsureDefaultCategoryUseCase ensure;
  late GetDefaultCategoryIdUseCase getId;

  setUp(() {
    repo = _StubRepo();
    ensure = EnsureDefaultCategoryUseCase(
      repo,
      GetOrCreateDefaultCategoryUseCase(repo, const Uuid()),
    );
    getId = GetDefaultCategoryIdUseCase(repo);
  });

  group('EnsureDefaultCategoryUseCase', () {
    test('creates the default when no categories exist', () async {
      final result = await ensure(
        const EnsureDefaultCategoryParams(localizedName: 'Daily'),
      );
      expect(result, isNotNull);
      expect(result!.name, 'Daily');
      expect(repo.marker, result.id);
      expect(repo.stored, hasLength(1));
    });

    test('creates nothing when categories exist and no marker', () async {
      repo.stored.add(_cat('x', 'Food'));
      final result = await ensure(
        const EnsureDefaultCategoryParams(localizedName: 'Daily'),
      );
      expect(result, isNull);
      expect(repo.stored, hasLength(1));
      expect(repo.marker, isNull);
    });

    test('is idempotent with a valid marker', () async {
      await ensure(const EnsureDefaultCategoryParams(localizedName: 'Daily'));
      final second = await ensure(
        const EnsureDefaultCategoryParams(localizedName: 'Daily'),
      );
      expect(second, isNull);
      expect(repo.stored, hasLength(1));
    });

    test('blank name throws emptyName when it would create', () {
      expect(
        () => ensure(const EnsureDefaultCategoryParams(localizedName: '  ')),
        throwsA(
          isA<CategoryValidationException>().having(
            (e) => e.error,
            'error',
            CategoryValidationError.emptyName,
          ),
        ),
      );
    });
  });

  group('GetDefaultCategoryIdUseCase', () {
    test('returns marker id when the category exists', () async {
      repo.stored.add(_cat('d', 'Daily'));
      repo.marker = 'd';
      expect(await getId(NoParams()), 'd');
    });

    test('null when marker unset', () async {
      expect(await getId(NoParams()), isNull);
    });

    test('null when marked category no longer exists', () async {
      repo.marker = 'gone';
      expect(await getId(NoParams()), isNull);
    });
  });
}
