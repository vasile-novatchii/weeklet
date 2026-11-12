---
phase: 15-amount-display-policy
plan: 02
subsystem: ui
tags: [flutter, number-formatter, expenses, income, integration-test]

# Dependency graph
requires:
  - phase: 15-amount-display-policy plan 01
    provides: "EllipsisTooltipText / ExpenseAmountText / WeekTotalRow already routed through the shared ellipsis+tooltip mechanism - this plan only swaps the formatter calls feeding them"
provides:
  - "Expense and income list rows (ExpenseAmountText call sites) render full fixed-2-decimal amounts via formatCurrencyWithSign"
  - "Expense and income week-group totals (WeekTotalRow call sites) render full fixed-2-decimal totals via formatCurrency/formatCurrencyWithSign"
  - "Expense CRUD integration test asserts against formatCurrencyWithSign, closing the Phase-8 contract-test drift"
affects: [15-03, 15-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Formatter-call swap only (formatCompact(WithSign) -> formatCurrency(WithSign)) at call sites whose layout/ellipsis wiring was already fixed by a prior plan"

key-files:
  created: []
  modified:
    - lib/presentation/screens/expenses/widgets/list/expense_item_view.dart
    - lib/presentation/screens/income/widgets/list/income_item_view.dart
    - lib/presentation/screens/expenses/widgets/list/expense_week_group_view.dart
    - lib/presentation/screens/income/widgets/list/income_week_group_view.dart
    - test/integration/expense_crud_flow_test.dart

key-decisions:
  - "No widget-level changes were needed at any of the four call sites - all ellipsis+tooltip wiring was already delivered by Plan 15-01's ExpenseAmountText/WeekTotalRow refactor, so this plan is a pure formatter-method-name swap"

patterns-established: []

requirements-completed: [FMT-01]

# Metrics
duration: 12min
completed: 2026-09-01
---

# Phase 15 Plan 02: Full-format expense/income list rows and week totals Summary

**Swapped `formatCompact(WithSign)` -> `formatCurrency(WithSign)` at the four expense/income list-screen call sites and rewrote the expense CRUD integration test's three formatter assertions to match, closing the Phase-8 contract-test drift flagged in STATE.md.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-09-01T14:37:00Z (approx.)
- **Completed:** 2026-09-01T14:49:06Z
- **Tasks:** 3 completed
- **Files modified:** 5

## Accomplishments
- `expense_item_view.dart` and `income_item_view.dart` now compute their row amount via `NumberFormatter.formatCurrencyWithSign` (full fixed-2-decimal, e.g. `39.98 MDL` / `+39.98 MDL`) instead of K-notation
- `expense_week_group_view.dart` (via `NumberFormatter.formatCurrency`) and `income_week_group_view.dart` (via `NumberFormatter.formatCurrencyWithSign`) now compute their week totals in the same full format
- `test/integration/expense_crud_flow_test.dart`'s three `find.text(...)` assertions now reference `formatCurrencyWithSign` instead of `formatCompactWithSign`, removing a latent bug where the test would silently start expecting K-notation if the test amounts were later raised above the compact threshold
- Full test suite: 263/263 passing (unchanged from Plan 15-01's baseline) - zero regressions
- Analyzer: exactly the 3 pre-existing baseline infos (`app_constants.dart:12`, `expenses_screen.dart:154`, `income_screen.dart:156`), 0 new issues
- Confirmed `annual_grouped_bar_chart.dart` (D-02/D-03 exemption) still calls `formatCompact`/`formatCompactWithSign` twice, untouched by this plan
- Confirmed no `formatCompact` occurrences remain anywhere under `lib/presentation/screens/expenses/widgets/list/` or `lib/presentation/screens/income/widgets/list/`

## Task Commits

1. **Task 1: Full-format the expense and income item rows** - `2bb0da6` (feat)
2. **Task 2: Full-format the expense and income week-group totals** - `1c78bc6` (feat)
3. **Task 3: Rewrite the expense CRUD integration test's formatter assertions** - `62ac133` (test)

**Plan metadata:** committed alongside this SUMMARY.

## Files Created/Modified
- `lib/presentation/screens/expenses/widgets/list/expense_item_view.dart` - `formattedAmount` now computed via `formatCurrencyWithSign`
- `lib/presentation/screens/income/widgets/list/income_item_view.dart` - `formattedAmount` now computed via `formatCurrencyWithSign`
- `lib/presentation/screens/expenses/widgets/list/expense_week_group_view.dart` - `formattedTotal` now computed via `formatCurrency`
- `lib/presentation/screens/income/widgets/list/income_week_group_view.dart` - `formattedTotal` now computed via `formatCurrencyWithSign`
- `test/integration/expense_crud_flow_test.dart` - three assertions rewritten to `formatCurrencyWithSign`, numeric literals and matcher types (`findsWidgets`/`findsNothing`) unchanged

## Decisions Made
- No widget-level (layout wrapper) changes were required at any of the four call sites this plan touches - `15-UI-SPEC.md` items 1, 2, 4, 5 all confirm "Layout wrapper: none needed" since the ellipsis+tooltip behavior was already inherited from Plan 15-01's `ExpenseAmountText`/`WeekTotalRow` refactor. This plan is scoped exclusively to `NumberFormatter` call-site swaps plus the one test-assertion rewrite.

## Deviations from Plan

None - plan executed exactly as written. All four production call sites and the three test assertions matched the plan's `<action>` blocks verbatim (same line content, same argument shapes); no unexpected structure was found during `read_first`.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Plan 15-02 is fully independent of Plans 15-03/15-04's remaining integration points (`income_total_card.dart`, `category_details_item.dart`, `modern_donut_chart.dart`, `monthly_bar_row.dart`, `monthly_item.dart`, `stats_balance_card.dart`, `stats_small_card.dart`) - no shared files were touched.
- `NumberFormatter` itself remains unmodified; `formatCompact`/`formatCompactWithSign` remain defined and are still exercised by the exempt `annual_grouped_bar_chart.dart` (D-02/D-03).
- Full test suite (263/263) and analyzer baseline (3 pre-existing infos) are both green, ready for Wave 2 plans to build on.

---
*Phase: 15-amount-display-policy*
*Completed: 2026-09-01*

## Self-Check: PASSED

- FOUND: lib/presentation/screens/expenses/widgets/list/expense_item_view.dart
- FOUND: lib/presentation/screens/income/widgets/list/income_item_view.dart
- FOUND: lib/presentation/screens/expenses/widgets/list/expense_week_group_view.dart
- FOUND: lib/presentation/screens/income/widgets/list/income_week_group_view.dart
- FOUND: test/integration/expense_crud_flow_test.dart
- FOUND: commit 2bb0da6 (feat(15-02): full-format expense and income list row amounts)
- FOUND: commit 1c78bc6 (feat(15-02): full-format expense and income week-group totals)
- FOUND: commit 62ac133 (test(15-02): assert full-format amounts in expense CRUD integration test)
