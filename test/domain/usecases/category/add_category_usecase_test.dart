import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';

// Minimal in-memory stub — no Hive, no DI
class _StubCategoryRepository implements CategoryRepository {
  Category? lastAdded;
  String? defaultCategoryId;
  final List<Category> _storedCategories = [];

  @override
  Future<void> addCategory(Category category) async {
    lastAdded = category;
    _storedCategories.add(category);
  }

  @override
  Future<List<Category>> getAllCategories() =>
      Future.value(List<Category>.from(_storedCategories));

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<Category?> getCategoryById(String id) => Future.value(null);

  @override
  Future<String?> getDefaultCategoryId() async => defaultCategoryId;

  @override
  Future<void> setDefaultCategoryId(String id) async => defaultCategoryId = id;
}

void main() {
  late _StubCategoryRepository repository;
  late AddCategoryUseCase useCase;

  setUp(() {
    repository = _StubCategoryRepository();
    useCase = AddCategoryUseCase(repository, const Uuid());
  });

  group('AddCategoryUseCase — basic validation', () {
    test('throws CategoryValidationException(emptyName) for empty name', () {
      expect(
        () async => useCase(
          AddCategoryParams(
            name: '',
            icon: 'food_icon',
            createdAt: DateTime(2024, 1, 15),
          ),
        ),
        throwsA(
          isA<CategoryValidationException>().having(
            (e) => e.error,
            'error',
            CategoryValidationError.emptyName,
          ),
        ),
      );
    });

    test(
      'throws CategoryValidationException(emptyName) for whitespace-only name',
      () {
        expect(
          () async => useCase(
            AddCategoryParams(
              name: '   ',
              icon: 'food_icon',
              createdAt: DateTime(2024, 1, 15),
            ),
          ),
          throwsA(
            isA<CategoryValidationException>().having(
              (e) => e.error,
              'error',
              CategoryValidationError.emptyName,
            ),
          ),
        );
      },
    );

    test('throws CategoryValidationException(emptyIcon) for empty icon', () {
      expect(
        () async => useCase(
          AddCategoryParams(
            name: 'Food',
            icon: '',
            createdAt: DateTime(2024, 1, 15),
          ),
        ),
        throwsA(
          isA<CategoryValidationException>().having(
            (e) => e.error,
            'error',
            CategoryValidationError.emptyIcon,
          ),
        ),
      );
    });

    test('succeeds for valid name and icon', () async {
      await expectLater(
        useCase(
          AddCategoryParams(
            name: 'Food',
            icon: 'food_icon',
            createdAt: DateTime(2024, 1, 15),
          ),
        ),
        completes,
      );
    });
  });

  group('AddCategoryUseCase — duplicate name prevention (D-01, D-02)', () {
    test(
      'throws CategoryValidationException(duplicateName) for exact name match',
      () async {
        await useCase(
          AddCategoryParams(
            name: 'Food',
            icon: 'food_icon',
            createdAt: DateTime(2024, 1, 15),
          ),
        );

        expect(
          () async => useCase(
            AddCategoryParams(
              name: 'Food',
              icon: 'other_icon',
              createdAt: DateTime(2024, 1, 16),
            ),
          ),
          throwsA(
            isA<CategoryValidationException>().having(
              (e) => e.error,
              'error',
              CategoryValidationError.duplicateName,
            ),
          ),
        );
      },
    );

    test(
      'throws CategoryValidationException(duplicateName) for same name in different case',
      () async {
        await useCase(
          AddCategoryParams(
            name: 'Food',
            icon: 'food_icon',
            createdAt: DateTime(2024, 1, 15),
          ),
        );

        expect(
          () async => useCase(
            AddCategoryParams(
              name: 'food',
              icon: 'other_icon',
              createdAt: DateTime(2024, 1, 16),
            ),
          ),
          throwsA(
            isA<CategoryValidationException>().having(
              (e) => e.error,
              'error',
              CategoryValidationError.duplicateName,
            ),
          ),
        );
      },
    );

    test(
      'completes without throwing for a different name when one category exists',
      () async {
        await useCase(
          AddCategoryParams(
            name: 'Food',
            icon: 'food_icon',
            createdAt: DateTime(2024, 1, 15),
          ),
        );

        await expectLater(
          useCase(
            AddCategoryParams(
              name: 'Transport',
              icon: 'car_icon',
              createdAt: DateTime(2024, 1, 16),
            ),
          ),
          completes,
        );
      },
    );
  });

  group('AddCategoryUseCase — UUID generation', () {
    test('lastAdded.id is non-empty after successful add', () async {
      await useCase(
        AddCategoryParams(
          name: 'Food',
          icon: 'food_icon',
          createdAt: DateTime(2024, 1, 15),
        ),
      );
      expect(repository.lastAdded, isNotNull);
      expect(repository.lastAdded!.id, isNotEmpty);
    });
  });

  group('AddCategoryUseCase — returns the created category (D-09)', () {
    test(
      'returned Category matches the record handed to repository.addCategory',
      () async {
        final created = await useCase(
          AddCategoryParams(
            name: 'Food',
            icon: 'food_icon',
            createdAt: DateTime(2024, 1, 15),
          ),
        );

        expect(repository.lastAdded, isNotNull);
        expect(created.id, repository.lastAdded!.id);
        expect(created.name, repository.lastAdded!.name);
        expect(created.icon, repository.lastAdded!.icon);
        expect(created.createdAt, repository.lastAdded!.createdAt);
      },
    );
  });
}
