import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_single_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/update_category_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';

// Configurable in-memory stub repository.
class _StubCategoryRepository implements CategoryRepository {
  _StubCategoryRepository({
    this.shouldThrow = false,
    this.returnedCategories = const [],
    this.returnedCategory,
  });

  bool shouldThrow;
  final List<Category> returnedCategories;
  final Category? returnedCategory;

  /// The last category handed to [addCategory]; also served back from
  /// [getAllCategories] so a reload sees what was just created.
  Category? lastAdded;
  final List<Category> _added = [];

  @override
  Future<void> addCategory(Category category) async {
    if (shouldThrow) throw Exception('add failed');
    lastAdded = category;
    _added.add(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    if (shouldThrow) throw Exception('delete failed');
  }

  @override
  Future<void> updateCategory(Category category) async {
    if (shouldThrow) throw Exception('update failed');
  }

  @override
  Future<List<Category>> getAllCategories() async {
    if (shouldThrow) throw Exception('get all failed');
    return [...returnedCategories, ..._added];
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    if (shouldThrow) throw Exception('get by id failed');
    return returnedCategory;
  }

  @override
  Future<void> clearAll() async {}

  @override
  Future<String?> getDefaultCategoryId() async => null;

  @override
  Future<void> setDefaultCategoryId(String id) async {}
}

// Shared fixture category
final _fixtureCategory = Category(
  id: 'cat-1',
  name: 'Food',
  icon: '🍎',
  createdAt: DateTime(2024, 1, 1),
);

// Helper that wires real use cases against a stub repository
CategoryBloc _makeBloc(_StubCategoryRepository repo) => CategoryBloc(
  addCategoryUseCase: AddCategoryUseCase(repo, const Uuid()),
  updateCategoryUseCase: UpdateCategoryUseCase(repo),
  deleteCategoryUseCase: DeleteCategoryUseCase(repo),
  getAllCategoriesUseCase: GetAllCategoriesUseCase(repo),
  getCategoryByIdUseCase: GetSingleCategoryUseCase(repo),
);

void main() {
  group('CategoryBloc', () {
    // CategoryState does NOT extend Equatable — use isA<>() matchers throughout

    test('initial state is CategoryLoading', () {
      final bloc = _makeBloc(_StubCategoryRepository());
      expect(bloc.state, isA<CategoryLoading>());
      bloc.close();
    });

    // ------------------------------------------------------------------
    // GetAllCategoriesEvent
    // ------------------------------------------------------------------
    blocTest<CategoryBloc, CategoryState>(
      'GetAllCategoriesEvent success emits [CategoryLoading, CategoriesLoaded]',
      build: () => _makeBloc(
        _StubCategoryRepository(returnedCategories: [_fixtureCategory]),
      ),
      act: (bloc) => bloc.add(const GetAllCategoriesEvent()),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'GetAllCategoriesEvent failure emits [CategoryLoading, CategoryError]',
      build: () => _makeBloc(_StubCategoryRepository(shouldThrow: true)),
      act: (bloc) => bloc.add(const GetAllCategoriesEvent()),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>(),
      ],
    );

    // ------------------------------------------------------------------
    // AddCategoryEvent
    // ------------------------------------------------------------------
    blocTest<CategoryBloc, CategoryState>(
      'AddCategoryEvent success emits 4 states ending in CategoriesLoaded'
          ' with CategorySuccess message == categoryAddedSuccess',
      build: () => _makeBloc(_StubCategoryRepository()),
      act: (bloc) => bloc.add(
        const AddCategoryEvent(name: 'Food', icon: '🍎'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategorySuccess>().having(
          (s) => s.message,
          'message',
          'categoryAddedSuccess',
        ),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'AddCategoryEvent with empty name emits '
          '[CategoryLoading, CategoryError] with emptyName error code',
      build: () => _makeBloc(_StubCategoryRepository()),
      act: (bloc) => bloc.add(
        const AddCategoryEvent(name: '', icon: '🍎'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>().having(
          (s) => s.message,
          'message',
          CategoryValidationError.emptyName.name,
        ),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'AddCategoryEvent generic error emits '
          '[CategoryLoading, CategoryError] with genericError',
      build: () => _makeBloc(_StubCategoryRepository(shouldThrow: true)),
      act: (bloc) => bloc.add(
        const AddCategoryEvent(name: 'Food', icon: '🍎'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>().having(
          (s) => s.message,
          'message',
          'genericError',
        ),
      ],
    );

    // ------------------------------------------------------------------
    // UpdateCategoryEvent
    // ------------------------------------------------------------------
    blocTest<CategoryBloc, CategoryState>(
      'UpdateCategoryEvent success emits 4 states ending in CategoriesLoaded',
      build: () => _makeBloc(_StubCategoryRepository()),
      act: (bloc) => bloc.add(
        UpdateCategoryEvent(
          id: 'cat-1',
          name: 'Updated Food',
          icon: '🥦',
          createdAt: DateTime(2024, 1, 1),
        ),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategorySuccess>().having(
          (s) => s.message,
          'message',
          'categoryUpdatedSuccess',
        ),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'UpdateCategoryEvent error emits [CategoryLoading, CategoryError]',
      build: () => _makeBloc(_StubCategoryRepository(shouldThrow: true)),
      act: (bloc) => bloc.add(
        UpdateCategoryEvent(
          id: 'cat-1',
          name: 'Food',
          icon: '🍎',
          createdAt: DateTime(2024, 1, 1),
        ),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>(),
      ],
    );

    // ------------------------------------------------------------------
    // DeleteCategoryEvent
    // ------------------------------------------------------------------
    blocTest<CategoryBloc, CategoryState>(
      'DeleteCategoryEvent success emits 4 states ending in CategoriesLoaded',
      build: () => _makeBloc(_StubCategoryRepository()),
      act: (bloc) => bloc.add(
        const DeleteCategoryEvent(id: 'cat-1'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategorySuccess>().having(
          (s) => s.message,
          'message',
          'categoryDeletedSuccess',
        ),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'DeleteCategoryEvent error emits [CategoryLoading, CategoryError]',
      build: () => _makeBloc(_StubCategoryRepository(shouldThrow: true)),
      act: (bloc) => bloc.add(
        const DeleteCategoryEvent(id: 'cat-1'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>(),
      ],
    );

    // ------------------------------------------------------------------
    // GetCategoryByIdEvent
    // ------------------------------------------------------------------
    blocTest<CategoryBloc, CategoryState>(
      'GetCategoryByIdEvent found emits [CategoryLoading, CategoryLoaded]',
      build: () => _makeBloc(
        _StubCategoryRepository(returnedCategory: _fixtureCategory),
      ),
      act: (bloc) => bloc.add(
        const GetCategoryByIdEvent(id: 'cat-1'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'GetCategoryByIdEvent not found emits '
          '[CategoryLoading, CategoryError] with errorCategoryNotFound',
      build: () => _makeBloc(
        _StubCategoryRepository(returnedCategory: null),
      ),
      act: (bloc) => bloc.add(
        const GetCategoryByIdEvent(id: 'cat-1'),
      ),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>().having(
          (s) => s.message,
          'message',
          'errorCategoryNotFound',
        ),
      ],
    );
  });

  // ------------------------------------------------------------------
  // D-10: the session's last created category id
  // ------------------------------------------------------------------
  group('CategoryBloc - D-10 last created category', () {
    late _StubCategoryRepository repo;

    blocTest<CategoryBloc, CategoryState>(
      'AddCategoryEvent stamps the created id on the reloaded CategoriesLoaded',
      build: () {
        repo = _StubCategoryRepository();
        return _makeBloc(repo);
      },
      act: (bloc) =>
          bloc.add(const AddCategoryEvent(name: 'Groceries', icon: 'home')),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategorySuccess>(),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>().having(
          (s) => s.lastCreatedCategoryId,
          'lastCreatedCategoryId',
          repo.lastAdded!.id,
        ),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'the marker survives a later, unrelated GetAllCategoriesEvent',
      build: () {
        repo = _StubCategoryRepository();
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const AddCategoryEvent(name: 'Groceries', icon: 'home'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const GetAllCategoriesEvent());
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<CategoriesLoaded>());
        expect(
          (state as CategoriesLoaded).lastCreatedCategoryId,
          repo.lastAdded!.id,
        );
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'ClearLastCreatedCategoryRequested nulls the marker for good',
      build: () {
        repo = _StubCategoryRepository();
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const AddCategoryEvent(name: 'Groceries', icon: 'home'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const ClearLastCreatedCategoryRequested());
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bloc.add(const GetAllCategoriesEvent());
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategorySuccess>(),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>().having(
          (s) => s.lastCreatedCategoryId,
          'lastCreatedCategoryId',
          isNotNull,
        ),
        isA<CategoriesLoaded>().having(
          (s) => s.lastCreatedCategoryId,
          'lastCreatedCategoryId',
          isNull,
        ),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>().having(
          (s) => s.lastCreatedCategoryId,
          'lastCreatedCategoryId',
          isNull,
        ),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'a failed AddCategoryEvent leaves lastCreatedCategoryId null',
      build: () {
        repo = _StubCategoryRepository(shouldThrow: true);
        return _makeBloc(repo);
      },
      act: (bloc) async {
        bloc.add(const AddCategoryEvent(name: 'Groceries', icon: 'home'));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        repo.shouldThrow = false;
        bloc.add(const GetAllCategoriesEvent());
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>(),
        isA<CategoryLoading>(),
        isA<CategoriesLoaded>().having(
          (s) => s.lastCreatedCategoryId,
          'lastCreatedCategoryId',
          isNull,
        ),
      ],
    );
  });
}
