import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weeklet/domain/entities/category.dart';
import 'package:weeklet/domain/exceptions/category_exceptions.dart';
import 'package:weeklet/domain/usecases/base/use_case.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_single_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/update_category_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_event.dart';
import 'package:weeklet/presentation/blocs/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getAllCategoriesUseCase,
    required this.getCategoryByIdUseCase,
  }) : super(const CategoryLoading()) {
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<GetAllCategoriesEvent>(_onGetAllCategories);
    on<GetCategoryByIdEvent>(_onGetCategoryById);
    on<ClearLastCreatedCategoryRequested>(_onClearLastCreatedCategory);
  }

  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final GetSingleCategoryUseCase getCategoryByIdUseCase;

  /// Session-scoped id of the category created via [AddCategoryEvent].
  /// Stamped on every subsequent [CategoriesLoaded] so it survives the reloads
  /// fired by `_onAddCategory` and by the add-expense form's `initState`.
  /// The bloc is a lazy singleton, so this resets naturally on app restart.
  String? _lastCreatedCategoryId;

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
      final categories = await getAllCategoriesUseCase(NoParams());
      emit(
        CategoriesLoaded(
          categories: categories,
          lastCreatedCategoryId: _lastCreatedCategoryId,
        ),
      );
    } catch (e) {
      debugPrint('error in _onGetAllCategories: $e');
      emit(const CategoryError(message: 'genericError'));
    }
  }

  void _onClearLastCreatedCategory(
    ClearLastCreatedCategoryRequested event,
    Emitter<CategoryState> emit,
  ) {
    _lastCreatedCategoryId = null;
    final current = state;
    if (current is CategoriesLoaded) {
      emit(CategoriesLoaded(categories: current.categories));
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
