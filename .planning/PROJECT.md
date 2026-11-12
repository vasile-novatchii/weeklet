# Weeklet

## What This Is

Weeklet is a Flutter app for simple personal finance management. Users track weekly expenses by category, record income, and view annual statistics. The app is local-first with no cloud dependency, targeting Romanian and Russian-speaking users who want financial control without complexity.

## Core Value

Users can always see where their money went — fast entry, accurate totals, no friction.

## Current State

**v1.3 E2E Polish shipped 2026-11-12** (tag `v1.3`). All 7 phases (14-20) complete, 17/17 requirements satisfied, 523 tests passing. Audit status `tech_debt`: no functional gaps; verification paperwork is thin (no VERIFICATION.md, several draft VALIDATION.md) and the release workflows have not yet been run live.

### What Ships in v1.3

- Data correctness: ISO week ordering with current week pinned, all categories visible in the donut, income filter follows new entries, safe default-category creation
- Full-format amounts app-wide with ellipsis trim and long-press tooltip (chart axis keeps compact notation by accepted exemption)
- Stats tab PDF export (year/month and all-months), Unicode PDF font, localized expense/income PDFs, Android Share/Print-Save sheet
- Month names, stats titles, week labels and date inputs follow the in-app language
- Income inline errors, filter-preserving pull-to-refresh, home income subtitle, licenses page, bottom sheets above system navigation
- GitHub Actions CI and tag-triggered signed, obfuscated split-per-ABI APK releases (see `docs/RELEASING.md`; needs owner keystore + 4 secrets)

### Architecture

- Flutter 3.47.7 (pinned via FVM), Dart ^3.11.0
- Clean Architecture: BLoC + GetIt DI + Hive local storage
- Typed domain exceptions; `AppLocalizations` in presentation only; EN/RO/RU
- 16,828 LOC Dart in lib/

### Known tech debt

- Release workflows untested live; tag-validation script and pinned action SHAs not independently verified
- ExpenseGrouping/IncomeGrouping duplicate week-sort/pin logic
- ~43 files fail `dart format`; GetIt registrations leak in blocTest tearDown
- SET-07 fix verified in code only, not re-tested on device

## Next Milestone Goals

Not yet defined. Run `/gsd:new-milestone`. Deferred candidates: CSV export, budgets, recurring transactions, Play Store distribution.

<details>
<summary>Previous milestones (v1.0 - v1.2)</summary>

- **v1.2 Testing** (2026-07-26): 0 → 169 tests across use cases, BLoCs, widgets and real-Hive integration flows; 27/27 requirements.
- **v1.1 UX Polish** (2026-05-03): UI polish and full EN/RO/RU localization.
- **v1.0 MVP** (2026-04-27): architecture cleanup, income, statistics, settings, PDF export, release assets.

</details>

---

## Requirements

### Validated

- ✓ **ARCH-01** — Use cases validate inputs and throw on failure — v1.0
- ✓ **ARCH-02** — UUID generation in use cases, not BLoCs — v1.0
- ✓ **ARCH-03** — StatsBloc preloaded at startup via AppInitializer — v1.0
- ✓ **ARCH-04** — Locale-aware month abbreviations via intl — v1.0
- ✓ **INC-01–04** — Income CRUD, weekly grouping, stats sync — v1.0
- ✓ **STATS-01–03** — Monthly/annual breakdowns, chart refresh on CRUD — v1.0
- ✓ **SET-01–05** — Biometric auth, theme, language, currency, data reset — v1.0
- ✓ **EXP-01–02** — PDF export for expenses and income — v1.0
- ✓ **REL-01–04** — Branded icon, splash screen, branded colors — v1.0
- ✓ **UX-01** — Centered empty state on expenses list — v1.1
- ✓ **UX-02** — PDF export hidden when list is empty — v1.1
- ✓ **UX-03** — Categories via AppBar icon; removed from bottom nav — v1.1
- ✓ **UX-04** — Annual evolution amounts fit on one line — v1.1
- ✓ **UX-05** — Scrollbar on all scrollable screens — v1.1
- ✓ **LOC-01** — Full EN/RO/RU localization, EN fallback for unsupported locales — v1.1
- ✓ **TEST-01–08** — Use case unit tests: validation, error handling, delete cases, filtering/grouping, PDF generation — v1.2 (Phase 10)
- ✓ **TEST-09–15** — BLoC state machine tests: all 6 BLoCs (Expense, Income, Category, Stats, Settings, Export) — v1.2 (Phase 11)
- ✓ **TEST-16–23** — Widget component tests: 5 screens + AmountFieldView/DateFieldView — v1.2 (Phase 12)
- ✓ **TEST-24–27** — Integration tests: expense/income CRUD flows, stats refresh, PDF export — real widget-driven, real Hive persistence — v1.2 (Phase 13)
- ✓ **INC-05–07** — Income filter follows new entry, inline modal errors, filter-preserving pull-to-refresh — v1.3
- ✓ **STATS-04** — Every spending category visible in the chart — v1.3
- ✓ **CAT-01** — First-expense category flow never overwrites — v1.3
- ✓ **FMT-01–02** — Full-format amounts with ellipsis + long-press tooltip (chart axis exempt) — v1.3
- ✓ **EXP-05–06** — Stats PDF export incl. all-months — v1.3
- ✓ **LOC-02–03** — Remaining strings and date inputs localized — v1.3
- ✓ **SET-06–07** — Licenses page, reset-section spacing — v1.3
- ✓ **UX-06–09** — Home income subtitle, contextual placeholders, week ordering, bottom sheets above system nav — v1.3

### Active

(None - next milestone requirements to be defined via `/gsd:new-milestone`.)

### Deferred

- **BUDG-01/02** — Monthly spending limits per category
- **AUTO-01** — Recurring transactions
- **EXP-03/04** — CSV export (expense + income)

---

## Constraints

- **Tech stack:** Flutter 3.47.7 (pinned via FVM); Dart ^3.11.0
- **Architecture:** Clean Architecture with BLoC must be maintained; layer separation is non-negotiable
- **Storage:** Hive only; no SQLite migration, no network calls
- **Platform:** iOS and Android primary; macOS/Linux/Windows folders present but not target platforms
- **Distribution:** GitHub Releases only (signed APKs); no Play Store for now

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Local-first with Hive | Simplicity — no backend, no auth, no sync | ✓ Validated v1.0 |
| BLoC for all state management | Established pattern, enforced by CLAUDE.md | ✓ Validated v1.0 |
| Romanian + Russian + system locale | Core user base; `intl` already a dependency | ✓ Validated v1.1 |
| `AppConstants.DEFAULT_CURRENCY` | Single source of truth for currency symbol | ✓ Validated v1.0 |
| `StatsBloc` preloaded in `AppInitializer` | Instant stats — no spinner on navigation | ✓ Validated v1.0 |
| Settings screen modeled on screenshot | User provided exact reference design | ✓ Validated v1.0 |
| Typed domain exceptions with enum codes | BLoCs emit codes, widgets translate — no English in domain | ✓ Validated v1.1 |
| Bare `Locale` objects (no country codes) | Matches `LocaleManager.supportedLocales`; avoids `Locale.==` mismatch | ✓ Validated v1.1 |
| `currencySymbol` passed to `AmountFieldView` | Required param prevents stale default; forces explicit passing | ✓ Validated v1.1 |
| `deletionDialog` button labels required (not defaulted) | Callers must pass l10n strings; no hardcoded English defaults | ✓ Validated v1.1 |
| Real Hive (temp dir) over fake repositories for integration tests | "Integration" phase should exercise the real persistence layer, not re-verify BLoC logic already covered by unit tests | ✓ Validated v1.2 |
| `LiveTestWidgetsFlutterBinding()` for tests with real Hive writes | `TestWidgetsFlutterBinding.ensureInitialized()` hangs forever on real `dart:io` Hive writes inside `testWidgets` — root-caused in Phase 13 | ✓ Validated v1.2 |
| Full-format amounts with ellipsis + tooltip (reverses v1.1 compact decision) | Precision over brevity; chart axis keeps compact notation | ✓ Good v1.3 |
| Default category tracked by stored id marker, not name | Prevents hijacking/overwrite of user categories; zero Hive schema change | ✓ Good v1.3 |
| Display-only 3% donut slice floor | Small categories stay visible without distorting real amounts | ✓ Good v1.3 |
| Tag-triggered signed + obfuscated APK release via GitHub Actions | Only owner key can produce releases | — Pending (not run live) |
| Hand-rolled PDF text extraction (zlib + Tj/TJ regex) over a new package | No suitable pure-Dart, FFI-free PDF text-extraction package exists on pub.dev; verified working against real production PDF output | ✓ Validated v1.2 |

## Out of Scope

- Cloud sync / backend — local-first is a core product constraint
- Web target — iOS and Android only
- Multi-currency — single currency per user; display setting only
- Onboarding flow — personal-use app; revisit if user acquisition becomes a goal
- Empty state centering for income/categories screens — expenses only per UX-01

---

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase:** Move requirements, log decisions, check "What This Is" accuracy.
**After each milestone:** Full review — core value check, Out of Scope audit, context update.

---
*Last updated: 2026-11-12 after v1.3 milestone*
