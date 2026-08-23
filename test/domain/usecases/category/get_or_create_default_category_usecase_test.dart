import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/category/get_or_create_default_category_usecase.dart';

// Minimal in-memory stub — no Hive, no DI.
// Mirrors the shape used by add_category_usecase_test.dart, plus a mutable
// marker so the id-based default resolution can be exercised directly.
class _StubCategoryRepository implements CategoryRepository {
  Category? lastAdded;
  String? defaultCategoryId;
  final List<Category> storedCategories = [];

  /// Seeds the store the way the data source returns it: ascending by
  /// `createdAt`, so "oldest match" is genuinely the first element.
  void seed(List<Category> categories) {
    storedCategories
      ..clear()
      ..addAll(categories)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> addCategory(Category category) async {
    lastAdded = category;
    storedCategories.add(category);
  }

  @override
  Future<List<Category>> getAllCategories() =>
      Future.value(List<Category>.from(storedCategories));

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<Category?> getCategoryById(String id) async {
    for (final c in storedCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<String?> getDefaultCategoryId() async => defaultCategoryId;

  @override
  Future<void> setDefaultCategoryId(String id) async => defaultCategoryId = id;
}

Category _category(
  String id,
  String name, {
  DateTime? createdAt,
  String icon = 'home',
}) => Category(
  id: id,
  name: name,
  icon: icon,
  createdAt: createdAt ?? DateTime(2024, 1, 1),
);

void main() {
  late _StubCategoryRepository repository;
  late GetOrCreateDefaultCategoryUseCase useCase;

  setUp(() {
    repository = _StubCategoryRepository();
    useCase = GetOrCreateDefaultCategoryUseCase(repository, const Uuid());
  });

  group('GetOrCreateDefaultCategoryUseCase — marker path (D-09)', () {
    test(
      'Case 1: marker pointing at an existing category returns it and '
      'creates nothing',
      () async {
        final existing = _category('cat-default', 'Daily');
        repository
          ..seed([existing, _category('cat-user', 'Groceries')])
          ..defaultCategoryId = 'cat-default';

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
        );

        expect(result, existing);
        expect(repository.lastAdded, isNull);
        expect(repository.defaultCategoryId, 'cat-default');
        expect(repository.storedCategories.length, 2);
      },
    );

    test(
      'Case 2: a renamed default is still resolved — identity is the id, '
      'not the name',
      () async {
        final renamed = _category('cat-default', 'Groceries and stuff');
        repository
          ..seed([renamed])
          ..defaultCategoryId = 'cat-default';

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
        );

        expect(result, renamed);
        expect(result.name, 'Groceries and stuff');
        expect(repository.lastAdded, isNull);
        expect(repository.defaultCategoryId, 'cat-default');
      },
    );

    test(
      'Case 3: a dangling marker self-heals — a fresh default is created and '
      'the marker is rewritten',
      () async {
        repository
          ..seed([_category('cat-user', 'Groceries')])
          ..defaultCategoryId = 'cat-deleted';

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Zilnic'),
        );

        expect(result.name, 'Zilnic');
        expect(repository.lastAdded, isNotNull);
        expect(repository.lastAdded!.id, result.id);
        expect(repository.defaultCategoryId, result.id);
        expect(repository.defaultCategoryId, isNot('cat-deleted'));
      },
    );
  });

  group('GetOrCreateDefaultCategoryUseCase — legacy adoption (D-08)', () {
    test(
      'Case 4: no marker but a category named "Daily" exists — it is adopted, '
      'not duplicated',
      () async {
        final legacy = _category('cat-legacy', 'Daily');
        repository.seed([legacy]);

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
        );

        expect(result, legacy);
        expect(repository.lastAdded, isNull);
        expect(repository.defaultCategoryId, 'cat-legacy');
        expect(repository.storedCategories.length, 1);
      },
    );

    test(
      'Case 5a: adoption is case-insensitive and whitespace-tolerant '
      '("  zilnic  ")',
      () async {
        final legacy = _category('cat-legacy', '  zilnic  ');
        repository.seed([legacy]);

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Zilnic'),
        );

        expect(result, legacy);
        expect(repository.lastAdded, isNull);
        expect(repository.defaultCategoryId, 'cat-legacy');
      },
    );

    test(
      'Case 5b: the Russian legacy name "Ежедневно" is adopted too',
      () async {
        final legacy = _category('cat-legacy', '  ЕЖЕДНЕВНО ');
        repository.seed([legacy]);

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Ежедневно'),
        );

        expect(result, legacy);
        expect(repository.lastAdded, isNull);
        expect(repository.defaultCategoryId, 'cat-legacy');
      },
    );

    test('Case 5c: every name in knownDefaultNames is adoptable', () async {
      for (final known in GetOrCreateDefaultCategoryUseCase.knownDefaultNames) {
        final repo = _StubCategoryRepository()
          ..seed([_category('cat-legacy', known)]);
        final uc = GetOrCreateDefaultCategoryUseCase(repo, const Uuid());

        final result = await uc(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
        );

        expect(result.id, 'cat-legacy', reason: 'failed adopting "$known"');
        expect(repo.lastAdded, isNull, reason: 'duplicated for "$known"');
      }
    });

    test(
      'Case 6: with two known-name matches the OLDEST by createdAt is adopted',
      () async {
        final older = _category(
          'cat-older',
          'Daily',
          createdAt: DateTime(2023, 5, 1),
        );
        final newer = _category(
          'cat-newer',
          'Zilnic',
          createdAt: DateTime(2024, 9, 1),
        );
        repository.seed([newer, older]);

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
        );

        expect(result, older);
        expect(repository.defaultCategoryId, 'cat-older');
        expect(repository.lastAdded, isNull);
      },
    );
  });

  group('GetOrCreateDefaultCategoryUseCase — creation (D-08 safety)', () {
    test(
      'Case 7: with only user categories present a NEW default is created and '
      'no user category is touched or returned',
      () async {
        final groceries = _category(
          'cat-groceries',
          'Groceries',
          icon: 'cart',
          createdAt: DateTime(2024, 2, 1),
        );
        final transport = _category(
          'cat-transport',
          'Transport',
          icon: 'car',
          createdAt: DateTime(2024, 3, 1),
        );
        repository.seed([groceries, transport]);

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
        );

        expect(result.name, 'Daily');
        expect(result.icon, 'home');
        expect(result.id, isNotEmpty);
        expect(result.id, isNot('cat-groceries'));
        expect(result.id, isNot('cat-transport'));
        expect(repository.defaultCategoryId, result.id);

        // Neither user category was mutated.
        expect(repository.storedCategories, contains(groceries));
        expect(repository.storedCategories, contains(transport));
        expect(repository.storedCategories.length, 3);
      },
    );

    test('Case 7b: a user category named "Daily" is never hijacked when the '
        'marker already points at the real default', () async {
      final realDefault = _category(
        'cat-default',
        'My spending',
        createdAt: DateTime(2023, 1, 1),
      );
      final userDaily = _category(
        'cat-user-daily',
        'Daily',
        createdAt: DateTime(2024, 6, 1),
      );
      repository
        ..seed([realDefault, userDaily])
        ..defaultCategoryId = 'cat-default';

      final result = await useCase(
        const GetOrCreateDefaultCategoryParams(localizedName: 'Daily'),
      );

      expect(result, realDefault);
      expect(result.id, isNot('cat-user-daily'));
      expect(repository.lastAdded, isNull);
    });
  });

  group('GetOrCreateDefaultCategoryUseCase — validation and guards', () {
    test(
      'Case 8a: an empty localized name throws '
      'CategoryValidationException(emptyName)',
      () {
        expect(
          () async => useCase(
            const GetOrCreateDefaultCategoryParams(localizedName: ''),
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

    test(
      'Case 8b: a whitespace-only localized name throws '
      'CategoryValidationException(emptyName)',
      () {
        expect(
          () async => useCase(
            const GetOrCreateDefaultCategoryParams(localizedName: '   '),
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

    test(
      'Case 9: creating the default never throws duplicateName — the '
      'regression guard for the silently aborted expense save',
      () async {
        // A user category collides with the localized default name, but is
        // NOT in knownDefaultNames, so adoption cannot fire and creation must
        // still succeed rather than throwing duplicateName.
        repository.seed([_category('cat-user', 'Everyday')]);

        final result = await useCase(
          const GetOrCreateDefaultCategoryParams(localizedName: 'Everyday'),
        );

        expect(result, isA<Category>());
        expect(result.name, 'Everyday');
        expect(result.id, isNot('cat-user'));
        expect(repository.defaultCategoryId, result.id);
      },
    );
  });
}
