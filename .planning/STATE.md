---
gsd_state_version: 1.0
milestone: v1.3
milestone_name: E2E Polish
status: executing
stopped_at: Completed 14-05-PLAN.md (CAT-01 default resolution moved into ExpenseBloc)
last_updated: "2026-08-23T18:45:00.000Z"
last_activity: 2026-08-23 -- Plan 14-05 complete, wave 2 closed, 250/250 tests green
progress:
  total_phases: 6
  completed_phases: 0
  total_plans: 6
  completed_plans: 5
  percent: 83
---

# Project State

**Status:** Executing Phase 14
**Last Updated:** 2026-08-20

## Project Reference

See: .planning/PROJECT.md (updated 2026-08-20)

**Core value:** Users can always see where their money went - fast entry, accurate totals, no friction.
**Current focus:** Phase 14 — Data Correctness Fixes

## Milestone History

- **v1.0 MVP** - Phases 1-7 - shipped 2026-04-27
- **v1.1 UX Polish** - Phases 8-9 - shipped 2026-05-03
- **v1.2 Testing** - Phases 10-13 - shipped 2026-07-26 (0 → 169 tests, 27/27 requirements)

## Accumulated Context

- **Open blockers:** none.
- **14-05 decision:** `AddExpenseStarted.categoryId` is nullable but still a `required` named parameter. Null means "no category selected, resolve the default"; keeping it required forces every call site to state its intent instead of falling into the fallback by omission.
- **14-05 decision:** the default is resolved inside `_onAddExpense`'s existing `try`, before `AddExpenseParams` is built. That placement is the whole fix - the widget's un-caught `await sl<AddCategoryUseCase>()` became a caught failure that emits `actionError`. A new `on CategoryValidationException` branch sits before the generic `catch` and passes `selectedMonth` explicitly like every other branch.
- **14-05 decision:** the `sl<CategoryBloc>().add(GetAllCategoriesEvent())` refresh is gated on `selectedCategoryId == null`. Gating keeps the common save path from touching GetIt for `CategoryBloc` at all, and keeps every pre-existing test free of that registration. Locked by bloc test Cases 5a and 5b - do not ungate it.
- **14-05 decision:** the locale-resolved default name travels as plain event data (`AddExpenseStarted.defaultCategoryName`) from `AppLocalizations` in the widget down to the use case, so the domain layer stays Flutter-free. There is no `'Daily'` literal anywhere in `lib/presentation/blocs/`.
- **14-05 correction:** the generated `lib/l10n/app_localizations*.dart` files are GITIGNORED in this repo (`.gitignore:63-65`), contrary to what 14-05-PLAN.md asserted. Edit the ARB files, run `fvm flutter gen-l10n`, and commit only the ARB sources. Future l10n plans should not expect the generated files in a diff.
- **14-05 gap closed:** `test/helpers/test_hive_env.dart` was missing a `GetOrCreateDefaultCategoryUseCase` registration (14-04 wired the settings-box datasource there but not the use case). Added in 14-05; the real-Hive graph now mirrors `service_locator.dart`.
- **14-05 note (no user-visible change yet):** the widget still computes a non-null `finalCategoryId` before dispatching, so the new BLoC branch is unreachable from the UI. It goes live in 14-06 when the widget fallback block (`add_expense_form_view.dart:87-136`) is deleted. CAT-01 stays Pending in REQUIREMENTS.md until then.
- **14-04 decision:** the default-category marker is a primitive `String` stored under `default_category_id` in the shared settings `Box<dynamic>`, NOT a `CategoryModel` `@HiveField`. `hive_generator` is commented out of `pubspec.yaml` (analyzer conflict with `bloc_test`), so `category_model.g.dart` cannot be regenerated and must never be hand-edited. Any future app-managed primitive marker should follow the same route - zero Hive schema change.
- **14-04 decision:** default-category identity is the stored id, never the name. Name matching survives only inside a one-time legacy adoption step over the closed set `{daily, zilnic, ежедневно}`, and is immediately superseded by an id marker so it can never run twice on the same database. A renamed default is still found; a user category named "Daily" can never be hijacked.
- **14-04 decision:** `GetOrCreateDefaultCategoryUseCase` creates via `repository.addCategory` directly, deliberately bypassing `AddCategoryUseCase`. The duplicate-name guard stays a user-facing rule only; routing the fallback through it re-creates the defect where an uncaught `CategoryValidationError.duplicateName` silently aborted the expense save. Locked by test Case 9 - do not "fix" this by re-routing through the use case.
- **14-04 decision:** a dangling marker (pointing at a deleted category) is treated as absent and falls through to adoption or creation, rewriting the marker - it never returns null and never throws.
- **14-04 note (no user-visible change yet):** this plan is domain plus data only. `add_expense_form_view.dart` still contains the widget-side `'daily'` fallback and still calls `sl<AddCategoryUseCase>()` directly; nothing calls the new use case yet. 14-05 moves resolution into `ExpenseBloc` with a localized name, 14-06 deletes the widget fallback. The D-11 layer violation is NOT closed until 14-06.
- **14-04 note for 14-05:** the localized name must be passed in as a plain `String` - the use case imports no Flutter package by design. The three ARB values must match `knownDefaultNames` semantically (EN "Daily" / RO "Zilnic" / RU "Ежедневно") so an already-populated database adopts its existing default rather than creating a second one.
- **Repo debt (confirmed again in 14-04):** `test/helpers/test_hive_env.dart` and `test/presentation/blocs/category/category_bloc_test.dart` both fail `dart format --set-exit-if-changed` at `HEAD`, independent of any phase-14 edit. Two more of the 44 legacy files. Still deliberately not reformatted inside correctness plans.
- **14-03 decision:** `LoadIncomesRequested` carries an explicit `hasFocus` flag alongside nullable `focusYear`/`focusMonth`, because `focusMonth: null` is a meaningful "keep All months" instruction (D-02) and must stay distinguishable from a plain reload. Any future filter mode (e.g. INC-07 preservation in Phase 18) should extend this event rather than add a parallel mechanism.
- **14-03 decision:** the jump target is computed inside the CRUD handler's `IncomeSuccess` pattern match, since the reload emits `IncomeLoading` and destroys the pre-add filter state before `_onLoadIncomes` runs.
- **14-03 decision:** an out-of-set focus value degrades safely - `focusYear` must exist in `availableYears`, and a non-null `focusMonth` absent from `availableMonths` falls back to `null` ("All months", always a valid dropdown item) rather than to the now-based month, so the Material dropdown can never assert.
- **14-03 decision:** delete keeps the parameterless now-based reset. No decision covers delete and INC-07 pull-to-refresh preservation is Phase 18 scope; bloc_test Cases 6 and 7 lock this so a later plan cannot absorb it silently.
- **14-03 behavior change (user-visible):** after adding or editing an income, the year/month filter follows that entry. With "All months" active the wide view is preserved and only the year moves. No snackbar and no new strings (D-04); the updated filter bar is the only feedback.
- **Test debt (non-blocking, found in 14-03):** `blocTest`'s inline `tearDown:` parameter runs INSIDE the test body, so a failed expectation skips it and leaks GetIt registrations into the next test as a bogus "already registered" cascade. The new 14-03 group registers/resets at group level instead; the other groups in `income_bloc_test.dart` and any other test using the inline idiom still carry the latent cascade.
- **14-02 decision:** chart-only distortion is confined to a task-local `displayValue` passed straight to `PieChartSectionData.value`; `stat.totalAmount` and `stat.percentage` are never reassigned, so legend, centre total, details-list amounts, and repository figures stay exact. Any future chart tweak must keep this separation.
- **14-02 decision:** locked display constants live at the single call site, not in a shared constants file: 0.03 minimum donut share and 0.02 minimum progress-bar fill, both taken verbatim from 14-UI-SPEC sections 1 and 3.
- **14-02 decision:** `<1%` is a deliberate hardcoded literal, not an ARB key (D-06 / UI-SPEC copywriting contract) - it is symbol-only and identical in EN/RO/RU.
- **14-02 behavior change (user-visible):** a touched donut slice below 1% now reads `<1%` instead of a truncated `0%`, and every non-zero category shows a visible progress-bar sliver. Zero-spend categories still render an empty track.
- **14-01 decision:** all calendar arithmetic runs on `DateTime.utc` components via the new shared `WeekUtils.isoWeekOf`; local-time `difference().inDays` is banned for date math (elapsed-time truncation across DST was the root cause of UX-08).
- **14-01 decision:** the ISO year is attributed from the week's Thursday, so week 0 and phantom week 53 are structurally impossible.
- **14-01 decision:** pure domain utilities that branch on the current time expose an optional `{DateTime? now}` seam defaulting to `DateTime.now()`, keeping time-dependent behavior deterministically testable without a fake-clock package.
- **14-01 behavior change (user-visible):** entries dated Dec 29-31 now render under the following ISO year's "Week 1" instead of a bogus "Week 53". Derived at render time; no stored data changed.
- **Repo debt (non-blocking):** 44 source files predate the current `analysis_options.yaml` formatter settings. Worth a dedicated `/gsd:quick` formatting pass, deliberately not folded into a correctness plan.
- **Milestone-wide constraint:** the 169-test suite must stay green after every phase; update assertions where behavior intentionally changes (e.g. amount formatting in Phase 15).
- **Decision reversal:** Phase 15 (FMT-01) deliberately reverses the v1.1 "compact all amounts" decision (quick task 260430-qou); the `formatCompact` contract tests from Phase 8 will need removal or rewrite.
- **Deferred (GSD process debt, non-blocking):** Phases 10 & 11 lack `VERIFICATION.md`/`VALIDATION.md`; Phase 12 `VALIDATION.md` unsigned. All 27 v1.2 requirements independently confirmed passing at audit (169/169).
- **Constraint note:** Flutter SDK upgrade explicitly deferred past v1.3 (see REQUIREMENTS.md Out of Scope).
- Full decision log and requirement outcomes: `.planning/PROJECT.md`. Milestone summaries: `.planning/MILESTONES.md`.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260430-qou | compact all amounts in all screens like we did in stats | 2026-04-30 | ba8ac1b | [260430-qou](./quick/260430-qou-compact-all-amounts-in-all-screens-like-/) |

## Current Position

Phase: 14 (Data Correctness Fixes) — EXECUTING
Plan: 6 of 6
Status: Executing Phase 14
Last activity: 2026-08-23 -- Plan 14-05 complete (CAT-01 in ExpenseBloc), 250/250 tests green

Progress: [████████░░] 83%

## Session Continuity

Last session: 2026-08-23T21:45:00+03:00
Stopped at: Completed 14-05-PLAN.md (CAT-01 default resolution moved into ExpenseBloc)
Resume file: .planning/phases/14-data-correctness-fixes/14-06-PLAN.md
Next: /gsd:execute-phase 14 (wave 2 complete; wave 3 starts with 14-06, the last plan of the phase)

Note: `fvm flutter pub get` was run this session to restore missing pinned packages
(flutter_bloc 9.1.1, bloc 9.2.0, bloc_test 10.0.0, mocktail 1.0.5, fl_chart 1.1.1)
that were absent from the pub cache; pubspec.lock unchanged. Baseline verified:
169/169 tests pass in 27s. `fvm flutter analyze` exits 1 on a clean tree due to 3
pre-existing infos (app_constants.dart:12, expenses_screen.dart:154,
income_screen.dart:156), so all plan gates use `--no-fatal-infos`.

Note (14-05): test suite is now 250/250 (244 + 6 new CAT-01 bloc cases); analyzer
still reports exactly the same 3 pre-existing infos. Four more legacy files were
confirmed format-dirty at HEAD (add_expense_form_view.dart, test_hive_env.dart,
add_expense_form_view_test.dart, expense_bloc_test.dart) and deliberately left
alone; every added line was verified to sit outside the formatter's diff hunks.

Note (14-01): test suite is now 218/218 (169 baseline + 49 new); analyzer still
reports exactly the same 3 pre-existing infos. Zero existing assertions changed.
Caution for later plans: `dart format <dir>` WRITES in place - it reformatted 44
out-of-scope legacy files during 14-01 and had to be reverted file by file. Use
`fvm dart format -o none --set-exit-if-changed <files>` to check formatting.
