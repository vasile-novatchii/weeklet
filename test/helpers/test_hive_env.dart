import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:uuid/uuid.dart';
import 'package:weeklet/core/services/biometric_service.dart';
import 'package:weeklet/data/datasources/local/category_local_datasource.dart';
import 'package:weeklet/data/datasources/local/expense_local_datasource.dart';
import 'package:weeklet/data/datasources/local/income_local_data_source.dart';
import 'package:weeklet/data/datasources/local/settings_local_data_source.dart';
import 'package:weeklet/data/models/category_model.dart';
import 'package:weeklet/data/models/expense_model.dart';
import 'package:weeklet/data/models/income_model.dart';
import 'package:weeklet/data/repositories/category_repository_impl.dart';
import 'package:weeklet/data/repositories/expense_repository_impl.dart';
import 'package:weeklet/data/repositories/income_repository_impl.dart';
import 'package:weeklet/data/repositories/settings_repository_impl.dart';
import 'package:weeklet/data/repositories/statistics_repository_impl.dart';
import 'package:weeklet/domain/repositories/category_repository.dart';
import 'package:weeklet/domain/repositories/expense_repository.dart';
import 'package:weeklet/domain/repositories/income_repository.dart';
import 'package:weeklet/domain/repositories/settings_repository.dart';
import 'package:weeklet/domain/repositories/statistics_repository.dart';
import 'package:weeklet/domain/usecases/category/add_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/delete_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:weeklet/domain/usecases/category/get_single_category_usecase.dart';
import 'package:weeklet/domain/usecases/category/update_category_usecase.dart';
import 'package:weeklet/domain/usecases/expense/add_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/delete_expense_usecase.dart';
import 'package:weeklet/domain/usecases/expense/get_all_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/expense/update_expense_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_expenses_usecase.dart';
import 'package:weeklet/domain/usecases/export/export_income_usecase.dart';
import 'package:weeklet/domain/usecases/income/add_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/delete_income_use_case.dart';
import 'package:weeklet/domain/usecases/income/get_incomes_use_case.dart';
import 'package:weeklet/domain/usecases/income/update_income_use_case.dart';
import 'package:weeklet/domain/usecases/settings/clear_preferences_usecase.dart';
import 'package:weeklet/domain/usecases/settings/get_settings_usecase.dart';
import 'package:weeklet/domain/usecases/settings/reset_all_data_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_biometric_enabled_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_currency_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_locale_usecase.dart';
import 'package:weeklet/domain/usecases/settings/save_theme_usecase.dart';
import 'package:weeklet/domain/usecases/stats/get_available_periods_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_evolution_stats_use_case.dart';
import 'package:weeklet/domain/usecases/stats/get_monthly_stats_use_case.dart';
import 'package:weeklet/presentation/blocs/category/category_bloc.dart';
import 'package:weeklet/presentation/blocs/expense/expense_bloc.dart';
import 'package:weeklet/presentation/blocs/export/export_bloc.dart';
import 'package:weeklet/presentation/blocs/income/income_bloc.dart';
import 'package:weeklet/presentation/blocs/settings/settings_bloc.dart';
import 'package:weeklet/presentation/blocs/stats/stats_bloc.dart';

/// Temp directory created by the most recent [initTestDi] call, cleaned up
/// by [teardownTestDi].
Directory? _tempDir;

/// Isolated temp directory backing [_TestTempPathProvider]'s directory
/// getters, created by [initTestDi] and removed by [teardownTestDi]. Keeps
/// PDF exports (deterministic filenames like `weeklet_expenses_july_2026.pdf`)
/// out of the shared, machine-wide [Directory.systemTemp] so concurrent
/// export tests can't collide (WR-04).
Directory? _exportTempDir;

/// Registers Hive's [TypeAdapter]s exactly once per test FILE.
///
/// Call this from `setUpAll` — never from [initTestDi] itself, since
/// `initTestDi`/`teardownTestDi` are meant to run per-test while adapter
/// registration must happen exactly once (Hive throws `HiveError` on a
/// double registration for the same typeId).
void registerHiveAdaptersOnce() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ExpenseModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(IncomeModelAdapter());
  }
}

/// A fake [PathProviderPlatform] that resolves every directory-returning
/// method to the OS temp directory, mirroring
/// `test/domain/usecases/export/export_expenses_usecase_test.dart`'s
/// `_FakePathProvider`.
class _TestTempPathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  /// Resolves to the per-test-run isolated [_exportTempDir] when available,
  /// falling back to the raw OS temp dir only if [initTestDi] has not run
  /// (WR-04).
  String get _basePath => (_exportTempDir ?? Directory.systemTemp).path;

  @override
  Future<String?> getTemporaryPath() async => _basePath;

  @override
  Future<String?> getApplicationDocumentsPath() async => _basePath;

  @override
  Future<String?> getApplicationSupportPath() async => _basePath;

  @override
  Future<String?> getApplicationCachePath() async => _basePath;

  @override
  Future<String?> getDownloadsPath() async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => null;

  @override
  Future<String?> getExternalStoragePath() async => null;

  @override
  Future<String?> getLibraryPath() async => null;
}

/// Installs [_TestTempPathProvider] as `PathProviderPlatform.instance`.
///
/// Harmless for flows that never touch `path_provider`; required for
/// TEST-27's `getTemporaryDirectory()` call inside `ExportExpensesUseCase`.
void registerTestPathProvider() {
  PathProviderPlatform.instance = _TestTempPathProvider();
}

/// Opens a fresh OS temp-directory-backed Hive instance and registers the
/// entire production DI graph into [GetIt.instance], mirroring
/// `lib/core/di/service_locator.dart`'s `init()` line for line (Hive boxes
/// through `ExportBloc`) except for the Hive init source directory.
///
/// Call in `setUp` (or at the start of a test) for true per-test isolation.
Future<void> initTestDi() async {
  _tempDir = await Directory.systemTemp.createTemp('weeklet_test_hive_');
  _exportTempDir = await Directory.systemTemp.createTemp('weeklet_test_export_');
  Hive.init(_tempDir!.path);

  final categoryBox = await Hive.openBox<CategoryModel>('categories');
  final expenseBox = await Hive.openBox<ExpenseModel>('expenses');
  final incomeBox = await Hive.openBox<IncomeModel>('incomes');
  final settingsBox = await Hive.openBox<dynamic>('settings');

  GetIt.instance.registerSingleton<Box<CategoryModel>>(categoryBox);
  GetIt.instance.registerSingleton<Box<ExpenseModel>>(expenseBox);
  GetIt.instance.registerSingleton<Box<IncomeModel>>(incomeBox);
  GetIt.instance.registerSingleton<Box<dynamic>>(settingsBox);

  GetIt.instance.registerLazySingleton(() => const Uuid());

  // DATA layer - DataSources
  GetIt.instance.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(
      GetIt.instance<Box<CategoryModel>>(),
      GetIt.instance<Box<dynamic>>(),
    ),
  );

  GetIt.instance.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(
      GetIt.instance<Box<ExpenseModel>>(),
    ),
  );

  GetIt.instance.registerLazySingleton<IncomeLocalDataSource>(
    () => IncomeLocalDataSourceImpl(
      GetIt.instance<Box<IncomeModel>>(),
    ),
  );

  GetIt.instance.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(GetIt.instance<Box<dynamic>>()),
  );

  // DATA layer - Repositories
  GetIt.instance.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      GetIt.instance<CategoryLocalDataSource>(),
    ),
  );

  GetIt.instance.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      GetIt.instance<ExpenseLocalDataSource>(),
    ),
  );

  GetIt.instance.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(
      GetIt.instance<IncomeLocalDataSource>(),
    ),
  );

  GetIt.instance.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(
      expenseRepository: GetIt.instance<ExpenseRepository>(),
      incomeRepository: GetIt.instance<IncomeRepository>(),
      categoryRepository: GetIt.instance<CategoryRepository>(),
    ),
  );

  GetIt.instance.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(GetIt.instance<SettingsLocalDataSource>()),
  );

  // DOMAIN layer - UseCases (Category)
  GetIt.instance.registerLazySingleton(
    () => AddCategoryUseCase(
      GetIt.instance<CategoryRepository>(),
      GetIt.instance<Uuid>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => DeleteCategoryUseCase(
      GetIt.instance<CategoryRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => UpdateCategoryUseCase(
      GetIt.instance<CategoryRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => GetAllCategoriesUseCase(
      GetIt.instance<CategoryRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => GetSingleCategoryUseCase(
      GetIt.instance<CategoryRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Expense)
  GetIt.instance.registerLazySingleton(
    () => AddExpenseUseCase(
      GetIt.instance<ExpenseRepository>(),
      GetIt.instance<Uuid>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => DeleteExpenseUseCase(
      GetIt.instance<ExpenseRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => UpdateExpenseUseCase(
      GetIt.instance<ExpenseRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => GetAllExpensesUseCase(
      GetIt.instance<ExpenseRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Income)
  GetIt.instance.registerLazySingleton(
    () => AddIncomeUseCase(
      GetIt.instance<IncomeRepository>(),
      GetIt.instance<Uuid>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => DeleteIncomeUseCase(
      GetIt.instance<IncomeRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => GetIncomesUseCase(
      GetIt.instance<IncomeRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => UpdateIncomeUseCase(
      GetIt.instance<IncomeRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Stats)
  GetIt.instance.registerLazySingleton(
    () => GetMonthlyStatsUseCase(
      GetIt.instance<StatisticsRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => GetEvolutionStatsUseCase(
      GetIt.instance<StatisticsRepository>(),
    ),
  );
  GetIt.instance.registerLazySingleton(
    () => GetAvailablePeriodsUseCase(
      GetIt.instance<StatisticsRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Settings)
  GetIt.instance.registerLazySingleton(
    () => GetSettingsUseCase(GetIt.instance<SettingsRepository>()),
  );
  GetIt.instance.registerLazySingleton(
    () => SaveThemeUseCase(GetIt.instance<SettingsRepository>()),
  );
  GetIt.instance.registerLazySingleton(
    () => SaveLocaleUseCase(GetIt.instance<SettingsRepository>()),
  );
  GetIt.instance.registerLazySingleton(
    () => SaveCurrencyUseCase(GetIt.instance<SettingsRepository>()),
  );
  GetIt.instance.registerLazySingleton(
    () => SaveBiometricEnabledUseCase(GetIt.instance<SettingsRepository>()),
  );
  GetIt.instance.registerLazySingleton(
    () => ClearPreferencesUseCase(GetIt.instance<SettingsRepository>()),
  );
  GetIt.instance.registerLazySingleton(
    () => ResetAllDataUseCase(
      expenseRepository: GetIt.instance<ExpenseRepository>(),
      incomeRepository: GetIt.instance<IncomeRepository>(),
      categoryRepository: GetIt.instance<CategoryRepository>(),
      settingsRepository: GetIt.instance<SettingsRepository>(),
    ),
  );

  // DOMAIN layer - UseCases (Export)
  GetIt.instance.registerLazySingleton(ExportExpensesUseCase.new);
  GetIt.instance.registerLazySingleton(ExportIncomeUseCase.new);

  // Settings BLoC — registered BEFORE other BLoCs per CLAUDE.md rule
  GetIt.instance.registerLazySingleton(BiometricService.new);

  GetIt.instance.registerLazySingleton(
    () => SettingsBloc(
      getSettingsUseCase: GetIt.instance<GetSettingsUseCase>(),
      saveThemeUseCase: GetIt.instance<SaveThemeUseCase>(),
      saveLocaleUseCase: GetIt.instance<SaveLocaleUseCase>(),
      saveCurrencyUseCase: GetIt.instance<SaveCurrencyUseCase>(),
      saveBiometricEnabledUseCase:
          GetIt.instance<SaveBiometricEnabledUseCase>(),
      clearPreferencesUseCase: GetIt.instance<ClearPreferencesUseCase>(),
      resetAllDataUseCase: GetIt.instance<ResetAllDataUseCase>(),
      biometricService: GetIt.instance<BiometricService>(),
    ),
  );

  GetIt.instance.registerLazySingleton(
    () => StatsBloc(
      getMonthlyStatsUseCase: GetIt.instance<GetMonthlyStatsUseCase>(),
      getEvolutionStatsUseCase: GetIt.instance<GetEvolutionStatsUseCase>(),
      getAvailablePeriodsUseCase: GetIt.instance<GetAvailablePeriodsUseCase>(),
    ),
  );

  // PRESENTATION layer - Blocs

  GetIt.instance.registerLazySingleton(
    () => CategoryBloc(
      addCategoryUseCase: GetIt.instance<AddCategoryUseCase>(),
      updateCategoryUseCase: GetIt.instance<UpdateCategoryUseCase>(),
      deleteCategoryUseCase: GetIt.instance<DeleteCategoryUseCase>(),
      getAllCategoriesUseCase: GetIt.instance<GetAllCategoriesUseCase>(),
      getCategoryByIdUseCase: GetIt.instance<GetSingleCategoryUseCase>(),
    ),
  );

  GetIt.instance.registerLazySingleton(
    () => IncomeBloc(
      addIncomeUseCase: GetIt.instance<AddIncomeUseCase>(),
      updateIncomeUseCase: GetIt.instance<UpdateIncomeUseCase>(),
      deleteIncomeUseCase: GetIt.instance<DeleteIncomeUseCase>(),
      getIncomesUseCase: GetIt.instance<GetIncomesUseCase>(),
    ),
  );

  GetIt.instance.registerLazySingleton(
    () => ExpenseBloc(
      addExpenseUseCase: GetIt.instance<AddExpenseUseCase>(),
      updateExpenseUseCase: GetIt.instance<UpdateExpenseUseCase>(),
      deleteExpenseUseCase: GetIt.instance<DeleteExpenseUseCase>(),
      getExpensesUseCase: GetIt.instance<GetAllExpensesUseCase>(),
    ),
  );

  GetIt.instance.registerLazySingleton(
    () => ExportBloc(
      exportExpensesUseCase: GetIt.instance<ExportExpensesUseCase>(),
      exportIncomeUseCase: GetIt.instance<ExportIncomeUseCase>(),
    ),
  );
}

/// Resets [GetIt.instance], deletes all Hive box files, and removes the temp
/// directory created by [initTestDi] — leaves zero residue for the next
/// test, even when the next `initTestDi()` reopens boxes with the same
/// names.
Future<void> teardownTestDi() async {
  // Close BLoCs explicitly before GetIt forgets about them — reset() does
  // not call close() since Bloc isn't a get_it Disposable and no dispose:
  // callback was supplied at registration, so their StreamControllers would
  // otherwise leak across per-test reuse (WR-02).
  for (final closeable in [
    if (GetIt.instance.isRegistered<SettingsBloc>())
      GetIt.instance<SettingsBloc>(),
    if (GetIt.instance.isRegistered<StatsBloc>()) GetIt.instance<StatsBloc>(),
    if (GetIt.instance.isRegistered<CategoryBloc>())
      GetIt.instance<CategoryBloc>(),
    if (GetIt.instance.isRegistered<IncomeBloc>()) GetIt.instance<IncomeBloc>(),
    if (GetIt.instance.isRegistered<ExpenseBloc>())
      GetIt.instance<ExpenseBloc>(),
    if (GetIt.instance.isRegistered<ExportBloc>()) GetIt.instance<ExportBloc>(),
  ]) {
    await closeable.close();
  }

  await GetIt.instance.reset();
  await Hive.deleteFromDisk();
  final dir = _tempDir;
  if (dir != null && dir.existsSync()) {
    await dir.delete(recursive: true);
  }
  _tempDir = null;

  final exportDir = _exportTempDir;
  if (exportDir != null && exportDir.existsSync()) {
    await exportDir.delete(recursive: true);
  }
  _exportTempDir = null;
}
