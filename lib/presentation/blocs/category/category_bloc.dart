import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/ensure_default_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_default_category_id_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_single_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/update_category_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';

/// Processes events strictly one at a time, in arrival order, so a startup
/// load can never emit a stale list after the default-category seeding.
/// Bloc applies transformers per registered event type, so [CategoryBloc]
/// registers a single handler for all events to share one queue.
EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getAllCategoriesUseCase,
    required this.getCategoryByIdUseCase,
    required this.ensureDefaultCategoryUseCase,
    required this.getDefaultCategoryIdUseCase,
  }) : super(const CategoryLoading()) {
    // One handler for every event: bloc applies transformers per event type,
    // so a single sequential queue is the only way to serialize across types.
    on<CategoryEvent>(_onEvent, transformer: _sequential());
  }

  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final GetSingleCategoryUseCase getCategoryByIdUseCase;
  final EnsureDefaultCategoryUseCase ensureDefaultCategoryUseCase;
  final GetDefaultCategoryIdUseCase getDefaultCategoryIdUseCase;

  /// Session-scoped id of the category created via [AddCategoryEvent].
  /// Stamped on every subsequent [CategoriesLoaded] so it survives the reloads
  /// fired by `_onAddCategory` and by the add-expense form's `initState`.
  /// The bloc is a lazy singleton, so this resets naturally on app restart.
  String? _lastCreatedCategoryId;

  Future<void> _onEvent(
    CategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    switch (event) {
      case final AddCategoryEvent e:
        await _onAddCategory(e, emit);
      case final UpdateCategoryEvent e:
        await _onUpdateCategory(e, emit);
      case final DeleteCategoryEvent e:
        await _onDeleteCategory(e, emit);
      case final GetAllCategoriesEvent e:
        await _onGetAllCategories(e, emit);
      case final GetCategoryByIdEvent e:
        await _onGetCategoryById(e, emit);
      case final EnsureDefaultCategoryRequested e:
        await _onEnsureDefaultCategory(e, emit);
      case final ClearLastCreatedCategoryRequested e:
        _onClearLastCreatedCategory(e, emit);
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final created = await addCategoryUseCase(
        AddCategoryParams(
          name: event.name,
          icon: event.icon,
          createdAt: DateTime.now(),
        ),
      );
      _lastCreatedCategoryId = created.id;
      emit(
        const CategorySuccess(
          message: 'categoryAddedSuccess',
        ),
      );
      add(const GetAllCategoriesEvent());
    } on CategoryValidationException catch (e) {
      debugPrint('error in _onAddCategory: $e');
      emit(
        CategoryError(message: e.error.name),
      );
    } catch (e) {
      debugPrint('error in _onAddCategory: $e');
      emit(
        const CategoryError(message: 'genericError'),
      );
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final category = Category(
        id: event.id,
        name: event.name,
        icon: event.icon,
        createdAt: event.createdAt,
      );
      await updateCategoryUseCase(category);
      emit(const CategorySuccess(message: 'categoryUpdatedSuccess'));
      add(const GetAllCategoriesEvent());
    } on CategoryValidationException catch (e) {
      debugPrint('error in _onUpdateCategory: $e');
      emit(CategoryError(message: e.error.name));
    } catch (e) {
      debugPrint('error in _onUpdateCategory: $e');
      emit(const CategoryError(message: 'genericError'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await deleteCategoryUseCase(event.id);
      emit(const CategorySuccess(message: 'categoryDeletedSuccess'));
      add(const GetAllCategoriesEvent());
    } on CategoryValidationException catch (e) {
      debugPrint('error in _onDeleteCategory: $e');
      emit(CategoryError(message: e.error.name));
    } catch (e) {
      debugPrint('error in _onDeleteCategory: $e');
      emit(const CategoryError(message: 'genericError'));
    }
  }

  Future<void> _onGetAllCategories(
    GetAllCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await _emitLoaded(emit);
    } catch (e) {
      debugPrint('error in _onGetAllCategories: $e');
      emit(const CategoryError(message: 'genericError'));
    }
  }

  Future<void> _onEnsureDefaultCategory(
    EnsureDefaultCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      await ensureDefaultCategoryUseCase(
        EnsureDefaultCategoryParams(localizedName: event.localizedName),
      );
      await _emitLoaded(emit);
    } catch (e) {
      debugPrint('error in _onEnsureDefaultCategory: $e');
      emit(const CategoryError(message: 'genericError'));
    }
  }

  Future<void> _emitLoaded(Emitter<CategoryState> emit) async {
    final categories = await getAllCategoriesUseCase(NoParams());
    final defaultId = await getDefaultCategoryIdUseCase(NoParams());
    emit(
      CategoriesLoaded(
        categories: categories,
        lastCreatedCategoryId: _lastCreatedCategoryId,
        defaultCategoryId: defaultId,
      ),
    );
  }

  void _onClearLastCreatedCategory(
    ClearLastCreatedCategoryRequested event,
    Emitter<CategoryState> emit,
  ) {
    _lastCreatedCategoryId = null;
    final current = state;
    if (current is CategoriesLoaded) {
      emit(
        CategoriesLoaded(
          categories: current.categories,
          defaultCategoryId: current.defaultCategoryId,
        ),
      );
    }
  }

  Future<void> _onGetCategoryById(
    GetCategoryByIdEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final category = await getCategoryByIdUseCase(event.id);
      if (category != null) {
        emit(CategoryLoaded(category: category));
      } else {
        emit(const CategoryError(message: 'errorCategoryNotFound'));
      }
    } on CategoryValidationException catch (e) {
      debugPrint('error in _onGetCategoryById: $e');
      emit(CategoryError(message: e.error.name));
    } catch (e) {
      debugPrint('error in _onGetCategoryById: $e');
      emit(const CategoryError(message: 'genericError'));
    }
  }
}
