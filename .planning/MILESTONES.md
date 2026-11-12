# Milestones

## v1.3 E2E Polish (Shipped: 2026-11-12)

**Phases completed:** 7 phases (14-20), 47 plans

**Delivered:** Every bug and UX gap from the e2e test findings fixed - correct full-format amounts, complete EN/RO/RU localization, reliable filters, stats PDF export, and a CI pipeline that publishes signed, obfuscated APK releases to GitHub. 17/17 requirements satisfied.

**Stats:**

- 7 phases · 47 plans · 17/17 requirements satisfied
- 523 tests passing (integration checker run at audit; 169 at v1.2 close)
- 173 files changed in lib/test, +11,933 / -1,568 since v1.2 (`git diff 9cf1014..HEAD -- lib test`)
- 16,828 LOC Dart in lib/ (excluding generated)
- Timeline: 2026-08-23 → 2026-11-12
- Git range: `057bcc6` (test(14-01)) → `844db30` (ci(20-03))

**Key accomplishments:**

- **Phase 14 - Data correctness:** shared UTC-based `WeekUtils.isoWeekOf` with current week pinned first; every category visible in the donut via a display-only 3% floor; income filter follows a newly added entry; first-expense flow no longer overwrites categories (`GetOrCreateDefaultCategoryUseCase`).
- **Phase 15 - Amount display policy:** full-format amounts app-wide with shared `EllipsisTooltipText` (ellipsis trim + long-press tooltip); chart axis/tooltip keep compact notation by accepted exemption.
- **Phase 16 - PDF export:** stats tab exports to PDF honoring year/month and all-months; Noto Sans Unicode font; localized expense/income PDFs; Android Share/Print-Save sheet; optional description; 4 UAT rounds closed.
- **Phase 17 - Localization:** month names, stats titles, week labels and date inputs follow the in-app language (UK format for EN).
- **Phase 18 - Income & home UX:** inline income modal errors, filter-preserving pull-to-refresh, home income subtitle, contextual description hints.
- **Phase 19 - Settings & system UI:** licenses page from the version card, reset-section spacing, bottom sheets above system navigation.
- **Phase 20 - CI & signed release:** GitHub Actions CI, tag-triggered signed + obfuscated split-per-ABI APKs with SHA256SUMS, `key.properties` signing with debug fallback, `docs/RELEASING.md`.

**Known deferred items at close:** 3 (see STATE.md Deferred Items). Audit status `tech_debt`: no VERIFICATION.md for any v1.3 phase (workflow.verifier=false); several VALIDATION.md still draft; release workflows not yet run live. See `.planning/milestones/v1.3-MILESTONE-AUDIT.md`.

---

## v1.2 Testing (Shipped: 2026-07-26)

**Phases completed:** 4 phases (10–13), 16 plans

**Delivered:** Comprehensive automated test infrastructure and coverage — the suite grew from **0 to 169 passing tests** across use cases, BLoCs, widgets, and real-Hive integration flows, with zero regressions and full 27/27 requirement coverage.

**Stats:**

- 4 phases · 16 plans · 27/27 requirements satisfied
- 169 tests passing (fresh full-suite run at audit, exit 0)
- 63 files changed, +11,626 / −90 since v1.1
- Timeline: 2026-05-21 → 2026-07-26 (test-hygiene fixes through close)
- Git range: `d9f74fb` → `9cf1014`

**Key accomplishments:**

- **Phase 10 — Use case unit tests:** validation (AddExpense/AddIncome/AddCategory incl. TDD case-insensitive duplicate-name guard), delete success/not-found, and year/month filtering for both filter utils (TEST-01–08).
- **Phase 11 — BLoC state machine tests:** all six BLoCs (Expense, Income, Category, Stats, Settings, Export) with `bloc_test`, Equatable-aware seeding, and `noSuchMethod` stubs / concrete `FakeStatsBloc` for GetIt CRUD-handler resolution (TEST-09–15).
- **Phase 12 — Widget component tests:** 5 screens + AmountFieldView/DateFieldView via a shared `pumpApp` helper and mocktail BLoCs; all four SettingsScreen toggles verified by real UI taps (TEST-16–23). Verified 8/8.
- **Phase 13 — Integration & critical-path tests:** 4 end-to-end flows (expense CRUD, income CRUD, stats refresh, PDF export) driven by real widget taps against a real Hive-backed DI graph, including byte-level PDF content verification via a hand-rolled `extractPdfText` (TEST-24–27). Verified 12/12; verifier independently re-ran the full suite.
- **Shared test infrastructure:** `test/helpers/test_hive_env.dart` (real temp-dir Hive + 46-registration DI graph mirroring `service_locator.dart`), `fake_share_platform.dart`, `pdf_text_extractor.dart`.
- **Post-verification hardening:** all four 13-REVIEW test-hygiene warnings (WR-01–04) and two info lints (IN-01/02) fixed before close.

**Known deferred items at close:** Phases 10 & 11 lack formal `VERIFICATION.md`/`VALIDATION.md` and Phase 12's `VALIDATION.md` is unsigned — GSD process-artifact debt only; all 27 requirements independently confirmed passing in the milestone audit. See `.planning/v1.2-MILESTONE-AUDIT.md`.

---

## v1.1 UX Polish (Shipped: 2026-05-03)

**Phases completed:** 9 phases, 33 plans, 47 tasks

**Key accomplishments:**

- Four failing RED test files covering use case validation (ARCH-01), UUID generation (ARCH-02), locale-aware month abbreviations (ARCH-04), and MDL currency constant (REL-03)
- Amount validation (string parse + <= 0 check) and UUID generation moved from BLoCs into AddExpenseUseCase, AddIncomeUseCase, and AddCategoryUseCase via new Params value objects
- One-liner:
- StatsBloc preloaded at startup via AppInitializer, chart month labels made locale-aware via DateFormat('MMM', locale), and dead GetExpensesByMonthYearUseCase deleted from disk and DI
- Romanian strings eliminated from income screen and StatsBloc dispatched after all three CRUD operations to keep statistics totals accurate
- All four INC requirements verified in running app — English strings visible, weekly grouping correct, CRUD with auto-close, stats screen syncs after income mutations
- Task 1 — Repository + use case pipeline fix (TDD):
- Dynamic 'Annual'/'Monthly' card labels wired via isAnnual flag; all hardcoded 'RON'/'lei' replaced with NumberFormatter; Romanian strings replaced with English across 9 stats files
- 1. [Rule 1 - Bug] Fixed test mocks missing clearAll() after interface extension
- SettingsBloc with 7 event handlers, BiometricService (local_auth 3.0.1 LocalAuthException API), MaterialApp driven by live BLoC state, and AppLifecycleListener biometric gate overlay
- SettingsScreen
- Failing test stubs for ExportExpensesUseCase (4 cases) and ExportIncomeUseCase (3 cases) — both RED via compile error because implementation files do not yet exist
- Both export use cases implement full PDF generation per UI-SPEC (header, summary row, data table, totals) via dart-pdf; ExportBloc wired into DI and app.dart; all 7 Wave 0 tests GREEN
- Both ExpensesScreen and IncomeScreen have functional PDF export icon buttons, BlocListeners for share sheet / error handling, and null-month guards — completing EXP-01 and EXP-02
- PathNotFoundException on macOS
- Branded launcher icons and native splash screens generated for iOS and Android using #1447E6 brand blue, with adaptive icon support (API 26+) and Android 12 windowSplashScreen compliance (API 31+)
- Branded icon and brand-blue (#1447E6) splash screen confirmed on Android emulator (API 33) — no white flash observed, no Dart changes required
- One-liner:
- Unconditional getEvolutionStatsUseCase call replacing year-equality guard in StatsBloc, so annual bar chart always reflects latest data after same-year CRUD operations
- Result: PASS
- Failing unit tests establishing formatCompact contract: K notation for amounts >= 1000, delegation to formatCurrency for amounts < 1000
- Utility additions completing TDD GREEN step and global scrollbar injection.
- 4-tab navigation and 4 targeted ExpensesScreen improvements.
- Income PDF conditional hide, sheet scroll opt-out, compact stat formatting.
- All remaining 6 modal bottom sheet builders wrapped with ScrollConfiguration.
- All 5 UX requirements verified by developer. Two gap fixes applied during visual inspection.
- RED test contracts locking typed exception API (ExpenseValidationException, IncomeValidationException) and LOC-01 supportedLocales invariants before Wave 1 implementation
- gen-l10n infrastructure with l10n.yaml, three ARB files (144 keys, EN/RO/RU), trimmed LocaleManager.supportedLocales to [en, ro, ru], and MaterialApp wired with AppLocalizations.delegate + localeResolutionCallback English fallback
- Three pure-Dart domain exception classes with enum error codes + full use-case and BLoC refactor to eliminate English error strings from the domain layer
- String extraction for Expenses, Categories, Settings, and Common widget trees: every hardcoded English literal replaced with AppLocalizations lookups; AmountFieldView refactored to accept currencySymbol; expense and category BLoC error codes translated via switch statements
- Complete localization of income, stats, navigation, and biometric gate widget trees — all hardcoded English strings replaced with AppLocalizations lookups; both income AmountFieldView callsites pass currencySymbol; income action-error switch translates BLoC codes to localized snackbars
- Result: PASS

---
