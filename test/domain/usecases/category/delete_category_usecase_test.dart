import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';

// Minimal in-memory stub — no Hive, no DI
class _StubCategoryRepository implements CategoryRepository {
  String? lastDeletedId;

  @override
  Future<void> deleteCategory(String id) async => lastDeletedId = id;

  @override
  Future<void> addCategory(Category category) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<List<Category>> getAllCategories() async => [];

  @override
  Future<Category?> getCategoryById(String id) => Future.value(null);

  @override
  Future<void> clearAll() async {}

  @override
  Future<String?> getDefaultCategoryId() async => null;

  @override
  Future<void> setDefaultCategoryId(String id) async {}
}

void main() {
  late _StubCategoryRepository repository;
  late DeleteCategoryUseCase useCase;

  setUp(() {
    repository = _StubCategoryRepository();
    useCase = DeleteCategoryUseCase(repository);
  });

  group('DeleteCategoryUseCase — validation', () {
    test(
      'throws CategoryValidationException(emptyCategoryId) for empty id',
      () {
        expect(
          () async => useCase(''),
          throwsA(
            isA<CategoryValidationException>().having(
              (e) => e.error,
              'error',
              CategoryValidationError.emptyCategoryId,
            ),
          ),
        );
      },
    );

    test(
      'throws CategoryValidationException(emptyCategoryId) for whitespace-only id',
      () {
        expect(
          () async => useCase('   '),
          throwsA(
            isA<CategoryValidationException>().having(
              (e) => e.error,
              'error',
              CategoryValidationError.emptyCategoryId,
            ),
          ),
        );
      },
    );

    test(
      'delegates to repository for valid id without throwing',
      () async {
        await expectLater(useCase('cat-789'), completes);
        expect(repository.lastDeletedId, 'cat-789');
      },
    );
  });
}
