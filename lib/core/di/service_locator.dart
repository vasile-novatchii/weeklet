import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/core/platform/pdf_print_service.dart';
import 'package:weeklet/core/services/biometric_service.dart';
import 'package:weeklet/core/utils/pdf_font_loader.dart';
import 'package:weeklet/data/datasources/local/category_local_datasource.dart';
import 'package:weeklet/data/datasources/local/expense_local_datasource.dart';
import 'package:weeklet/data/datasources/local/settings_local_data_source.dart';
import 'package:weeklet/data/models/category_model.dart';
import 'package:weeklet/data/models/expense_model.dart';
import 'package:weeklet/data/repositories/category_repository_impl.dart';
import 'package:weeklet/data/repositories/expense_repository_impl.dart';
import 'package:weeklet/data/repositories/settings_repository_impl.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/usecases/settings/clear_preferences_usecase.dart';
import 'package:weeklet/domain/usecases/settings/get_settings_usecase.dart';
import 'package:weeklet/domain/usecases/settings/reset_all_data_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_biometric_enabled_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_currency_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_locale_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_theme_usecase.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/ensure_default_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_default_category_id_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_or_create_default_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_single_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/update_category_usecase.dart';
import 'package:weeklet/domain/usecases/expense/add_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/delete_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/get_all_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/expense/update_expense_usecase.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';
import 'package:weeklet/data/repositories/statistics_repository_impl.dart';
import 'package:weeklet/domain/repositories/statistics_repository.dart';
import 'package:weeklet/domain/usecases/stats/get_available_periods_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_monthly_stats_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_evolution_stats_use_case.dart';
import 'package:weeklet/data/datasources/local/income_local_data_source.dart';
import 'package:weeklet/data/models/income_model.dart';
import 'package:weeklet/data/repositories/income_repository_impl.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/usecases/income/add_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/delete_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/get_incomes_use_case.dart';
import 'package:weeklet/domain/usecases/income/update_income_use_case.dart';
import 'package:weeklet/domain/usecases/export/export_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_income_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_stats_usecase.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Register adapters
  Hive.registerAdapter(
    CategoryModelAdapter(),
  );
  Hive.registerAdapter(
    ExpenseModelAdapter(),
  );
  Hive.registerAdapter(
    IncomeModelAdapter(),
  );

  // Open boxes and register singletons
  final categoryBox = await Hive.openBox<CategoryModel>(
    'categories',
  );
  final expenseBox = await Hive.openBox<ExpenseModel>(
    'expenses',
  );
  final incomeBox = await Hive.openBox<IncomeModel>(
    'incomes',
  );

  sl.registerSingleton<Box<CategoryModel>>(categoryBox);
  sl.registerSingleton<Box<ExpenseModel>>(expenseBox);
  sl.registerSingleton<Box<IncomeModel>>(incomeBox);

  // Settings box (Box<dynamic> — no adapter needed, primitives stored natively)
  final settingsBox = await Hive.openBox<dynamic>('settings');
  sl.registerSingleton<Box<dynamic>>(settingsBox);

  sl.registerLazySingleton(
    () => const Uuid(),
  );
  sl.registerLazySingleton(PdfFontLoader.new);
  sl.registerLazySingleton(PdfPrintService.new);

  // DATA layer - DataSources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(
      sl<Box<CategoryModel>>(),
      sl<Box<dynamic>>(),
    ),
  );

  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(
      sl<Box<ExpenseModel>>(),
    ),
  );

  sl.registerLazySingleton<IncomeLocalDataSource>(
    () => IncomeLocalDataSourceImpl(
      sl<Box<IncomeModel>>(),
    ),
  );

  // Settings DataSource
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sl<Box<dynamic>>()),
  );

  // DATA layer - Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      sl<CategoryLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      sl<ExpenseLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(
      sl<IncomeLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(
      expenseRepository: sl<ExpenseRepository>(),
      incomeRepository: sl<IncomeRepository>(),
      categoryRepository: sl<CategoryRepository>(),
    ),
  );

  // Settings Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl<SettingsLocalDataSource>()),
  );

  // DOMAIN layer - UseCases (Category)
  sl.registerLazySingleton(
    () => AddCategoryUseCase(
      sl<CategoryRepository>(),
      sl<Uuid>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteCategoryUseCase(
      sl<CategoryRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => UpdateCategoryUseCase(
      sl<CategoryRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetAllCategoriesUseCase(
      sl<CategoryRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetSingleCategoryUseCase(
      sl<CategoryRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetOrCreateDefaultCategoryUseCase(
      sl<CategoryRepository>(),
      sl<Uuid>(),
    ),
  );

  sl.registerLazySingleton(
    () => EnsureDefaultCategoryUseCase(
      sl<CategoryRepository>(),
      sl<GetOrCreateDefaultCategoryUseCase>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetDefaultCategoryIdUseCase(
      sl<CategoryRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Expense)
  sl.registerLazySingleton(
    () => AddExpenseUseCase(
      sl<ExpenseRepository>(),
      sl<Uuid>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteExpenseUseCase(
      sl<ExpenseRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => UpdateExpenseUseCase(
      sl<ExpenseRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetAllExpensesUseCase(
      sl<ExpenseRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Income)
  sl.registerLazySingleton(
    () => AddIncomeUseCase(
      sl<IncomeRepository>(),
      sl<Uuid>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteIncomeUseCase(
      sl<IncomeRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetIncomesUseCase(
      sl<IncomeRepository>(),
    ),
  );

  sl.registerLazySingleton(
    () => UpdateIncomeUseCase(
      sl<IncomeRepository>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetMonthlyStatsUseCase(
      sl<StatisticsRepository>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetEvolutionStatsUseCase(
      sl<StatisticsRepository>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetAvailablePeriodsUseCase(
      sl<StatisticsRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Settings)
  sl.registerLazySingleton(
    () => GetSettingsUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveThemeUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveLocaleUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveCurrencyUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveBiometricEnabledUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => ClearPreferencesUseCase(sl<SettingsRepository>()),
  );
  sl.registerLazySingleton(
    () => ResetAllDataUseCase(
      expenseRepository: sl<ExpenseRepository>(),
      incomeRepository: sl<IncomeRepository>(),
      categoryRepository: sl<CategoryRepository>(),
      settingsRepository: sl<SettingsRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Export)
  sl.registerLazySingleton(ExportExpensesUseCase.new);
  sl.registerLazySingleton(ExportIncomeUseCase.new);
  sl.registerLazySingleton(ExportStatsUseCase.new);

  // Settings BLoC — registered BEFORE other BLoCs per CLAUDE.md rule
  sl.registerLazySingleton(BiometricService.new);

  sl.registerLazySingleton(
    () => SettingsBloc(
      getSettingsUseCase: sl<GetSettingsUseCase>(),
      saveThemeUseCase: sl<SaveThemeUseCase>(),
      saveLocaleUseCase: sl<SaveLocaleUseCase>(),
      saveCurrencyUseCase: sl<SaveCurrencyUseCase>(),
      saveBiometricEnabledUseCase: sl<SaveBiometricEnabledUseCase>(),
      clearPreferencesUseCase: sl<ClearPreferencesUseCase>(),
      resetAllDataUseCase: sl<ResetAllDataUseCase>(),
      biometricService: sl<BiometricService>(),
    ),
  );

  sl.registerLazySingleton(
    () => StatsBloc(
      getMonthlyStatsUseCase: sl<GetMonthlyStatsUseCase>(),
      getEvolutionStatsUseCase: sl<GetEvolutionStatsUseCase>(),
      getAvailablePeriodsUseCase: sl<GetAvailablePeriodsUseCase>(),
    ),
  );

  // PRESENTATION layer - Blocs

  // Category
  sl.registerLazySingleton(
    () => CategoryBloc(
      addCategoryUseCase: sl<AddCategoryUseCase>(),
      updateCategoryUseCase: sl<UpdateCategoryUseCase>(),
      deleteCategoryUseCase: sl<DeleteCategoryUseCase>(),
      getAllCategoriesUseCase: sl<GetAllCategoriesUseCase>(),
      getCategoryByIdUseCase: sl<GetSingleCategoryUseCase>(),
      ensureDefaultCategoryUseCase: sl<EnsureDefaultCategoryUseCase>(),
      getDefaultCategoryIdUseCase: sl<GetDefaultCategoryIdUseCase>(),
    ),
  );

  // Income
  sl.registerLazySingleton(
    () => IncomeBloc(
      addIncomeUseCase: sl<AddIncomeUseCase>(),
      updateIncomeUseCase: sl<UpdateIncomeUseCase>(),
      deleteIncomeUseCase: sl<DeleteIncomeUseCase>(),
      getIncomesUseCase: sl<GetIncomesUseCase>(),
    ),
  );

  // Expense
  sl.registerLazySingleton(
    () => ExpenseBloc(
      addExpenseUseCase: sl<AddExpenseUseCase>(),
      updateExpenseUseCase: sl<UpdateExpenseUseCase>(),
      deleteExpenseUseCase: sl<DeleteExpenseUseCase>(),
      getExpensesUseCase: sl<GetAllExpensesUseCase>(),
      getOrCreateDefaultCategoryUseCase:
          sl<GetOrCreateDefaultCategoryUseCase>(),
    ),
  );

  // Export
  sl.registerLazySingleton(
    () => ExportBloc(
      exportExpensesUseCase: sl<ExportExpensesUseCase>(),
      exportIncomeUseCase: sl<ExportIncomeUseCase>(),
      exportStatsUseCase: sl<ExportStatsUseCase>(),
      fontLoader: sl<PdfFontLoader>(),
    ),
  );
}
