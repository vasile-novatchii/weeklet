# Claude Code Rules for Weeklet Project

## Architecture

Clean Architecture with Flutter BLoC, GetIt DI, and Hive local storage.

```
lib/
├── core/        # DI, router, theme, extensions, utils
├── domain/      # entities, repository interfaces, use cases, domain utils
├── data/        # Hive models, data sources, repository implementations
└── presentation/ # BLoC, screens, widgets
```

### Layer Separation Rules

**Widgets** — UI and user interaction only:
- Dispatch BLoC events; never call repositories or use cases directly
- Never contain validation, calculations, or formatting logic
- Use `NumberFormatter` for amounts, domain utils for grouping — no raw logic
- Receive data as constructor parameters; don't dig into BLoC state deep in the tree

**BLoC** — orchestration only:
- Call use cases, never repositories directly
- Manage filter/pagination state (`selectedYear`, `selectedMonth`, etc.)
- Emit loading → success/failure; catch use case exceptions into error states
- No business rules or data formatting

**Use Cases** — all business logic:
- Validate inputs and throw exceptions on failure
- Call repository methods for data operations
- No UI, no Hive, no Flutter dependencies

**Repositories** — data abstraction only:
- Convert Models ↔ Entities; this is the only place this happens
- Delegate storage to data sources; no business logic

**Data Sources** — storage only:
- Work with Hive Models exclusively; no entity conversion

---

## Rules & Conventions

### Use Cases
- Every business operation needs a dedicated use case in `lib/domain/usecases/<feature>/`
- Implement `UseCase<ReturnType, Params>` from `lib/domain/usecases/base/use_case.dart`
- File naming: `add_expense_usecase.dart` (single word `usecase`, no underscore)
- Class naming: `AddExpenseUseCase`, `GetSingleCategoryUseCase`
- Throw exceptions for validation errors — BLoC catches them

### Data Layer
- **Data sources** work with Models only (Hive operations, no conversion)
- **Repositories** do all Model ↔ Entity conversion — nowhere else
- `StatisticsRepository` is composite: takes `ExpenseRepository`, `IncomeRepository`, `CategoryRepository`

### BLoC
- Sealed classes + `final class` subtypes for events and states
- Event handlers are private: `_onAddExpense`
- Success states carry filter state: `selectedYear`, `selectedMonth`, `availableYears`, `availableMonths`, `allExpenses`, `filteredExpenses`
- `actionError` field on success states for CRUD failures that don't leave the screen — use `copyWith(actionError: e.toString())`
- State class names: `ExpenseInitial`, `ExpenseLoading`, `ExpenseSuccess`, `ExpenseFailure` (not `ExpenseError`)

### Dependency Injection
- All registrations in [lib/core/di/service_locator.dart](lib/core/di/service_locator.dart)
- Registration order: Hive init → box singletons → utilities → data sources → repositories → use cases → BLoCs
- `StatsBloc` is registered before other BLoCs
- Always use `sl<Type>()` — never `new` or constructor calls for services
- `registerSingleton` for Hive boxes, `registerLazySingleton` for everything else

### Widgets
- Use `NumberFormatter` for all amount display — never format raw doubles in widgets
- Use domain utils for grouping: `ExpenseGrouping`, `IncomeGrouping`, `ExpenseFilterUtils`
- Use `export.dart` barrel files in widget subdirectories

### App Initialization
- `AppInitializer` (`lib/presentation/app_initializer.dart`) triggers initial data loads in `initState`
- Add new BLoC initial events there if data is needed on startup

---

## Available Utilities

**Context extensions** (`lib/core/extensions/context_extensions.dart`): `context.theme`, `context.colorScheme`, `context.textTheme`, `context.screenWidth/Height`, `context.isDarkMode`, `context.push()`, `context.pop()`, `context.showSnackBar()`, `context.showErrorSnackBar()`, `context.showSuccessSnackBar()`, `context.showCustomDialog()`, `context.unfocus()`, `context.locale`

**FormValidators** (`lib/core/utils/form_validators.dart`): `required`, `amountFormat`, `minLength`, `maxLength`, `compose([...])`

**NumberFormatter** (`lib/core/utils/number_formatter.dart`): `formatCurrency`, `formatCurrencyWithSign`

**Domain utils** (`lib/domain/utils/`): `ExpenseGrouping.groupByWeek/Day`, `IncomeGrouping.groupByWeek/Day`, `ExpenseFilterUtils.extractAvailableYears/Months`, `IncomeFilterUtils`

**Routes** (`lib/core/router/app_routes.dart`): `home`, `expensesScreen`, `incomeScreen`, `categoriesScreen`, `addCategoryScreen`, `statsScreen`, `settingsScreen`

---

## New Feature Checklist

- [ ] Entity in `lib/domain/entities/`
- [ ] Repository interface in `lib/domain/repositories/`
- [ ] Use cases in `lib/domain/usecases/<feature>/`
- [ ] Hive model in `lib/data/models/` with `fromEntity`/`toEntity`
- [ ] Data source in `lib/data/datasources/local/`
- [ ] Repository impl in `lib/data/repositories/`
- [ ] BLoC (events, states, bloc) in `lib/presentation/blocs/<feature>/`
- [ ] Register adapter, boxes, data source, repo, use cases, BLoC in `service_locator.dart`
- [ ] Screen + widgets in `lib/presentation/screens/<feature>/`
- [ ] Route in `app_routes.dart` if needed
- [ ] `BlocProvider.value(value: sl<FeatureBloc>())` in [lib/app.dart](lib/app.dart)
- [ ] Initial load event in `app_initializer.dart` if needed

---

## Reference Patterns

Follow existing code for concrete examples:
- Screen structure → [lib/presentation/screens/expenses/](lib/presentation/screens/expenses/)
- BLoC patterns → [lib/presentation/blocs/expense/](lib/presentation/blocs/expense/)
- Use case examples → [lib/domain/usecases/expense/](lib/domain/usecases/expense/)
- DI registration → [lib/core/di/service_locator.dart](lib/core/di/service_locator.dart)

<!-- GSD:project-start source:PROJECT.md -->
## Project

**Weeklet**

Weeklet is a Flutter app for simple personal finance management. Users track weekly expenses by category, record income, and view annual statistics. The app is local-first with no cloud dependency, targeting Romanian and Russian-speaking users who want financial control without complexity.

**Core Value:** Users can always see where their money went — fast entry, accurate totals, no friction.

### Constraints

- **Tech stack:** Flutter 3.47.7 (pinned via FVM); Dart ^3.11.0 (SDK Dart 3.13.5); upgraded to 3.47.7 on 2026-10-19
- **Architecture:** Clean Architecture with BLoC must be maintained; layer separation is non-negotiable
- **Storage:** Hive only; no SQLite migration, no network calls
- **Platform:** iOS and Android primary; macOS/Linux/Windows folders present but not target platforms
- **Release:** Targeting public App Store / Play Store — requires proper icon, splash, localization completeness, stability
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Runtime
- **Flutter:** 3.47.7 (pinned via FVM - see `.fvmrc`; upgraded 2026-10-19)
- **Dart SDK:** ^3.11.0 constraint in `pubspec.yaml` (null-safe); the 3.47.7 SDK bundles Dart 3.13.5
- **FVM (Flutter Version Manager):** manages the Flutter SDK installation; use `fvm flutter` instead of `flutter` commands locally
## Package Manager
- **pub** (bundled with Flutter/Dart)
- Lockfile: `pubspec.lock` present and committed
## Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | UI framework |
| `flutter_bloc` | ^9.1.1 | BLoC state management; `Bloc`, `Cubit`, `BlocProvider`, `BlocBuilder`, `BlocListener`, `MultiBlocProvider` |
| `get_it` | ^9.0.5 | Service locator / dependency injection via global `sl` instance in `lib/core/di/service_locator.dart` |
| `hive` | ^2.2.3 | NoSQL local key-value storage; used for all persistent data |
| `hive_flutter` | ^1.1.0 | Hive Flutter integration; provides `Hive.init()` and Flutter box watcher support |
| `equatable` | ^2.0.8 | Value equality for entities, models, BLoC states and events |
| `fl_chart` | ^1.1.1 | Chart widgets used in the stats screen (`lib/presentation/screens/stats/`) - bar charts, donut/pie charts |
| `intl` | ^0.20.2 | Locale-aware number and date formatting via `NumberFormatter` (`lib/core/utils/number_formatter.dart`) and `LocaleManager` (`lib/core/utils/locale_manager.dart`) |
| `flutter_localizations` | SDK | Material/Cupertino/Widgets localization delegates wired in `lib/app.dart` |
| `path_provider` | ^2.1.5 | Resolves the application documents directory for Hive initialization and export files |
| `collection` | ^1.19.1 | Declared; currently not imported directly in `lib/` |
| `stream_transform` | ^2.1.1 | Stream operators (`debounce`, `switchMap`) used in `ExpenseBloc` event transformer (`lib/presentation/blocs/expense/expense_bloc.dart`) |
| `uuid` | ^4.5.2 | UUID v4 generation for entity IDs; singleton registered in DI as `Uuid` |
| `pdf` | ^3.12.0 | PDF document generation for expense, income and stats exports (`lib/domain/usecases/export/`) |
| `share_plus` | ^13.0.0 | Native share sheet hand-off for exported PDFs (`lib/presentation/utils/pdf_share_helper.dart`) |
| `local_auth` | ^3.0.1 | Biometric / device-credential authentication via `BiometricService` (`lib/core/services/biometric_service.dart`); uses `LocalAuthException` |
| `package_info_plus` | ^10.0.0 | App version display in the settings screen (`lib/presentation/screens/settings/settings_screen.dart`) |
## Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Flutter testing framework (unit, widget tests) |
| `flutter_lints` | ^6.0.0 | Base lint ruleset; extended by `analysis_options.yaml` |
| `bloc_test` | ^10.0.0 | BLoC testing helpers (`blocTest`) |
| `mocktail` | ^1.0.5 | Mocking library for use case, repository and service tests |
| `build_runner` | ^2.4.7 | Code generation runner (only needed if Hive adapters are regenerated) |
| `hive_generator` | ^2.0.1 | Commented out in `pubspec.yaml` (conflicts with `bloc_test` analyzer version); re-add only when regenerating models |
| `path_provider_platform_interface` | ^2.1.2 | Fake path provider platform in export file store tests |
| `plugin_platform_interface` | any | Base class for fake platform implementations in tests |
| `share_plus_platform_interface` | ^7.0.0 | Fake share platform in integration tests |
| `flutter_launcher_icons` | ^0.14.4 | Generates platform launcher icons from a single source asset |
| `flutter_native_splash` | ^2.4.7 | Generates native splash screens for iOS and Android |
## Build & Code Generation
- Hive adapters are checked-in generated files; `hive_generator` is currently disabled, so they are maintained by hand unless it is re-enabled and `build_runner` is run
- `lib/data/models/category_model.g.dart` - `CategoryModelAdapter` (typeId: 0)
- `lib/data/models/expense_model.g.dart` - `ExpenseModelAdapter` (typeId: 1)
- `lib/data/models/income_model.g.dart` - `IncomeModelAdapter` (typeId: 2)
- Localizations are generated by `flutter gen-l10n` (`generate: true` in `pubspec.yaml`)
## Android Toolchain
- Gradle wrapper 9.3.1 (`android/gradle/wrapper/gradle-wrapper.properties`), AGP 9.1.0 and Kotlin Gradle plugin 2.4.0 (`android/settings.gradle.kts`), Java 17 target - versions taken from the Flutter 3.47.7 app template
- `android/gradle.properties` keeps `android.newDsl=false` and `android.builtInKotlin=false`: Flutter 3.47.7 still requires opting out of the AGP 9 new DSL and built-in Kotlin (its own template sets both flags). Removing them fails the build
- `android/app/build.gradle.kts` uses the `kotlin { compilerOptions { ... } }` block instead of the deprecated `kotlinOptions`
## Linting & Static Analysis
- Extends `flutter_lints/flutter.yaml`
- Strict mode enabled: `strict-casts: true`, `strict-inference: true`, `strict-raw-types: true`
- `missing_required_param` and `missing_return` are treated as errors
- Key enforced rules: `prefer_single_quotes`, `require_trailing_commas`, `prefer_const_constructors`, `prefer_final_fields/locals`, `avoid_print`
- Page width: 80 characters
## Theming
- Material 3 (`useMaterial3: true`) with light and dark themes defined in `lib/core/theme/theme.dart`
- Color palette in `lib/core/theme/colors.dart`
- Theme switched automatically by system brightness
## Platform Targets
| Platform | Status | Notes |
|----------|--------|-------|
| Android | Active | `android/` directory present; Gradle Kotlin DSL (`build.gradle.kts`) |
| iOS | Active | `ios/` directory with Xcode project and CocoaPods (`Podfile`) |
| macOS | Present | `macos/` directory with CMakeLists.txt |
| Linux | Present | `linux/` directory with CMakeLists.txt |
| Windows | Present | `windows/` directory with CMakeLists.txt |
| Web | Not detected | No `web/` directory found |
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming
- Dart source files use `snake_case`: `expense_bloc.dart`, `add_expense_usecase.dart`
- Use case files: single word suffix with no underscore before it — `add_expense_usecase.dart` (not `add_expense_use_case.dart`)
- Exception: income use cases use `_use_case.dart` (two words, underscore): `add_income_use_case.dart` — inconsistency to be aware of
- Hive model files: `expense_model.dart`; generated files: `expense_model.g.dart` (excluded from analysis)
- Extension files: `context_extensions.dart`, `date_time_extensions.dart`
- Barrel files named exactly `export.dart`
- `PascalCase` everywhere: `ExpenseBloc`, `AddExpenseUseCase`, `ExpenseRepositoryImpl`, `ExpenseLocalDataSourceImpl`
- Use case suffix: `UseCase` (e.g., `AddExpenseUseCase`, `GetSingleCategoryUseCase`)
- Repository interface: `ExpenseRepository`; implementation: `ExpenseRepositoryImpl`
- Data source interface: `ExpenseLocalDataSource`; implementation: `ExpenseLocalDataSourceImpl`
- Hive model: `ExpenseModel`
- BLoC events: `PascalCase` + past/action tense verbs — `AddExpenseStarted`, `LoadExpensesRequested`, `DeleteExpenseStarted`, `FilterDateChanged`
- BLoC states: `PascalCasePrefix` + noun — `ExpenseInitial`, `ExpenseLoading`, `ExpenseSuccess`, `ExpenseFailure`
- Domain entity: plain noun — `Expense`, `Category`, `Income`
- Utility/helper classes: `ExpenseGrouping`, `NumberFormatter`, `FormValidators`
- `camelCase` for all methods
- BLoC event handlers are private and prefixed with `_on`: `_onLoadExpenses`, `_onAddExpense`, `_onDeleteExpense`, `_onFilterDateChanged`
- Private state variables prefixed with `_`: `_scrollController`, `_formKey`, `_amountController`
- Private utility methods: `_validateDate`, `_buildMenuItems`, `_showAddExpenseSheet`
- Static factory methods on model classes: `fromEntity` (named consistently across all models)
- Conversion methods on model instance: `toEntity()`
- `camelCase` for locals and instance fields
- Constants: `SCREAMING_SNAKE_CASE` (enforced by `constant_identifier_names` lint)
- `final` preferred for locals and fields (`prefer_final_locals`, `prefer_final_fields` enabled)
- Generic type parameters: single capital letter (`T`, `E`)
- Abstract classes and interfaces are plain names (no `I` prefix): `ExpenseRepository`, `ExpenseLocalDataSource`
## BLoC Pattern
- `sealed class XxxEvent extends Equatable` with `const XxxEvent()` constructor
- Each concrete event is `final class`, extending the sealed base
- All fields are `final` and declared after the constructor
- Every event overrides `props` with all its fields
- Events are doc-commented with `///`
- Four standard states per feature: `XxxInitial`, `XxxLoading`, `XxxSuccess`, `XxxFailure`
- Exception: `StatsBloc` uses `StatsError` instead of `StatsFailure` — inconsistency
- `ExpenseSuccess` / `MonthlyStatsLoaded` carry full filter state: `selectedYear`, `selectedMonth`, `availableYears`, `availableMonths`
- `actionError` field (nullable `String?`) on success state for CRUD failures that don't navigate away
- `copyWith` on every success state; nullable fields require special handling to allow resetting to null (don't use `?? this.field` for `selectedMonth` or `actionError`)
- All use cases injected through named constructor parameters
- Event handler registration in constructor body
- Handler methods are private, named `_onXxx`
- Pattern-match on state with `if (state case final XxxSuccess st)` before CRUD handlers
- After CRUD success, trigger reload by calling `add(const LoadExpensesRequested())`
- `debugPrint` for errors (not `print` — enforced by `avoid_print` lint)
## Widget Pattern
- Constructor always has `super.key`
- Required params before optional; optional params have defaults
- All fields are `final`
- No business logic — `NumberFormatter` for display, `context.colorScheme` / `context.textTheme` via extensions
- Private `_` prefix for state class fields
- Scroll controllers and text controllers declared as `late` and disposed in `dispose()`
- `initState` triggers initial BLoC events via `sl<XxxBloc>().add(...)`
- `mounted` check before `context.read` calls after `async` gaps
- `context.watch<XxxBloc>().state` used in `build` for rendering
- `BlocListener` / `BlocConsumer` used for side effects (navigation, snackbars)
- Success + `actionError == null` pattern for closing bottom sheets on successful CRUD
- `NumberFormatter.formatCurrency(amount, symbol)` — `lib/core/utils/number_formatter.dart`
- `NumberFormatter.formatCurrencyWithSign(amount, symbol, isIncome: isIncome)` — same file
- `NumberFormatter.formatTime(dateTime)` — same file
- `FormValidators.required(value)`, `FormValidators.compose([...])` — `lib/core/utils/form_validators.dart`
- `ExpenseGrouping.groupByWeek(expenses)` — `lib/domain/utils/expense_grouping.dart`
- Dialogs expose a `static Future<bool> show(BuildContext context)` method
- Used as: `UnsavedChangesDialog.show(context)`, `CustomConfirmationDialog.show(context: context, ...)`
## Use Case Pattern
- Implements `UseCase<ReturnType, Params>` from `lib/domain/usecases/base/use_case.dart`
- Exception: income use cases do not implement the `UseCase` interface (inconsistency)
- Single positional constructor param for the injected repository
- `const` constructor
- Private `_validateXxx` helper method for validation
- Throws `ArgumentError` for validation errors (expense), `Exception` for income use cases — inconsistency
- `NoParams` class used when no input needed: `getExpensesUseCase(NoParams())`
## Data Layer Pattern
- `static factory ExpenseModel.fromEntity(Expense entity)` — converts Entity → Model
- Instance method `toEntity()` — converts Model → Entity
- Conversion happens exclusively in Repository implementations
- Every repository method wraps the data source call in `try/catch`
- Errors are logged with `debugPrint('[ClassName.methodName] error: $e')`
- Errors are re-thrown (`rethrow`) — never swallowed
## Error Handling
- BLoC handlers: `debugPrint('error in _onXxx: $e')`
- Repository methods: `debugPrint('[ClassName.methodName] error: $e')`
- No `print` — enforced by `avoid_print` lint rule
## Imports and Exports
- Named `export.dart` (not `index.dart`)
- Found in widget subdirectories: `lib/presentation/screens/expenses/widgets/add/export.dart`, `lib/presentation/screens/expenses/widgets/list/export.dart`, `lib/presentation/widgets/common/form/export.dart`
- Not used universally — some subdirectories have no barrel file
- Always use absolute package paths for cross-directory imports: `package:weeklet/domain/entities/expense.dart`
- Relative imports only for same-directory siblings
## Linting
- `avoid_print: true` — use `debugPrint` instead
- `prefer_single_quotes: true` — all string literals use single quotes
- `camel_case_types: true` — class and type names are PascalCase
- `constant_identifier_names: true` — constants use SCREAMING_SNAKE_CASE
- `prefer_const_constructors: true` — use `const` wherever possible
- `prefer_const_literals_to_create_immutables: true`
- `require_trailing_commas: true` — trailing commas required in multi-line argument lists
- `sort_child_properties_last: true` — Flutter widget `child`/`children` goes last
- `sort_constructors_first: true` — constructor before fields
- `prefer_final_fields: true`, `prefer_final_locals: true`, `prefer_final_in_for_each: true`
- `unnecessary_lambdas: true`, `prefer_expression_function_bodies: true`
- `slash_for_doc_comments: true` — use `///` not `/** */`
- `unawaited_futures: true` — always await futures
- `use_super_parameters: false` — super parameters NOT enforced (opted out)
- Generated files excluded: `**/*.g.dart`, `**/*.freezed.dart`
- `missing_required_param: error`, `missing_return: error`
- `todo: ignore` — TODOs silenced
- Strict mode: `strict-casts: true`, `strict-inference: true`, `strict-raw-types: true`
- Page width: 80 characters
- `trailing_commas: preserve`
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern
## Layers
### Presentation
- **Purpose:** UI rendering and user interaction. Dispatches BLoC events; never calls use cases or repositories directly.
- **Location:** `lib/presentation/`
- **Contains:**
- **Depends on:** Domain (entities + use case interfaces via BLoC), Core (extensions, formatters, theme)
- **Must NOT:** Call repositories, use cases, or Hive directly
### Domain
- **Purpose:** All business logic. Zero Flutter or Hive dependencies.
- **Location:** `lib/domain/`
- **Contains:**
- **Depends on:** Nothing (no imports from `data/` or `presentation/`)
- **Base contract:** `lib/domain/usecases/base/use_case.dart` — `abstract class UseCase<T, P> { Future<T> call(P params); }`
### Data
- **Purpose:** Storage operations. Converts between Hive models and domain entities.
- **Location:** `lib/data/`
- **Contains:**
- **Depends on:** Domain (entities and repository interfaces only)
- **Key rule:** Model ↔ Entity conversion happens ONLY in repositories, never in data sources or BLoCs
### Core
- **Purpose:** Cross-cutting infrastructure shared across all layers.
- **Location:** `lib/core/`
- **Contains:**
## Data Flow
### Read (UI ← Storage)
```
```
### Write (UI → Storage)
```
```
### Filter / Pagination (client-side)
## Dependency Injection
## Key Patterns
### BLoC Structure (Sealed Events + States)
```dart
```
```dart
```
### UseCase Contract
```dart
```
### Model ↔ Entity Conversion
```dart
```
### Statistics Repository (Composite)
### Routing
### Theme
### Localization
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
