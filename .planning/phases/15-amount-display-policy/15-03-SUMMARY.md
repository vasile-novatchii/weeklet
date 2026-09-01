---
phase: 15-amount-display-policy
plan: 03
subsystem: ui
tags: [flutter, number-formatting, tooltip, ellipsis, income, stats]

# Dependency graph
requires:
  - phase: 15-amount-display-policy
    provides: "EllipsisTooltipText widget (Plan 15-01) - single-line ellipsis-trim + long-press tooltip"
provides:
  - "income_total_card.dart, stats_balance_card.dart, stats_small_card.dart all render full fixed-2-decimal amounts via formatCurrencyWithSign + EllipsisTooltipText"
  - "stats_balance_card.dart's headline amount gains overflow protection for the first time (previously zero)"
  - "income_crud_flow_test.dart and stats_refresh_flow_test.dart integration test assertions updated to match the new formatter"
affects: [15-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Direct EllipsisTooltipText(text:, style:) as a Column child needs no Flexible/SizedBox wrapper when the parent is already width-bounded (SizedBox/Container width: double.infinity)"

key-files:
  created: []
  modified:
    - lib/presentation/screens/income/widgets/income_total_card.dart
    - lib/presentation/screens/stats/widgets/stats_summary_cards/stats_balance_card.dart
    - lib/presentation/screens/stats/widgets/stats_summary_cards/stats_small_card.dart
    - test/integration/income_crud_flow_test.dart
    - test/integration/stats_refresh_flow_test.dart

key-decisions:
  - "No layout wrapper (Flexible/SizedBox) added at any of the three call sites - all three already sit inside a width-bounded parent (SizedBox/Container width: double.infinity), matching 15-UI-SPEC.md items 3, 10, 11"
  - "stats_small_card.dart's pre-existing overflow: TextOverflow.ellipsis / maxLines: 1 params were dropped from the Text call site since EllipsisTooltipText applies them internally"

patterns-established: []

requirements-completed: [FMT-01, FMT-02]

# Metrics
duration: 12min
completed: 2026-09-01
---

# Phase 15 Plan 3: Full-format income total and stats summary cards Summary

**Wired formatCurrencyWithSign + EllipsisTooltipText into income_total_card, stats_balance_card, and stats_small_card, giving stats_balance_card overflow protection for the first time, and rewrote the two integration tests that assert against those amounts.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-09-01T14:43:00Z
- **Completed:** 2026-09-01T14:55:54Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments
- `income_total_card.dart`'s headline total now uses `formatCurrencyWithSign` and renders through `EllipsisTooltipText`
- `stats_balance_card.dart`'s balance amount now uses `formatCurrencyWithSign` and renders through `EllipsisTooltipText` - this `Text` had zero overflow protection before this plan
- `stats_small_card.dart`'s amount now uses `formatCurrencyWithSign` and renders through `EllipsisTooltipText`, consolidating its pre-existing partial `overflow`/`maxLines` wiring into the shared widget
- `income_crud_flow_test.dart` and `stats_refresh_flow_test.dart` rewritten to assert `formatCurrencyWithSign`, both passing against the production changes above

## Task Commits

Each task was committed atomically:

1. **Task 1: Full-format and wrap income_total_card.dart and stats_balance_card.dart** - `63a2537` (feat)
2. **Task 2: Full-format and wrap stats_small_card.dart** - `6f4844f` (feat)
3. **Task 3: Rewrite the income CRUD and stats-refresh integration test assertions** - `6ce82ed` (test)

_No separate plan-metadata commit - orchestrator owns STATE.md/ROADMAP.md updates for this parallel-executor run._

## Files Created/Modified
- `lib/presentation/screens/income/widgets/income_total_card.dart` - `formatCompactWithSign` -> `formatCurrencyWithSign`; `Text` -> `EllipsisTooltipText`
- `lib/presentation/screens/stats/widgets/stats_summary_cards/stats_balance_card.dart` - same swap; first overflow protection added to this amount
- `lib/presentation/screens/stats/widgets/stats_summary_cards/stats_small_card.dart` - same swap; dropped now-redundant `overflow`/`maxLines` params (handled internally by `EllipsisTooltipText`)
- `test/integration/income_crud_flow_test.dart` - assertion updated to `formatCurrencyWithSign`
- `test/integration/stats_refresh_flow_test.dart` - assertion updated to `formatCurrencyWithSign`

## Decisions Made
- No layout wrapper needed at any of the three call sites - confirmed by the plan's own analysis and verified visually via `flutter analyze` type-checking against the surrounding `Column`/`SizedBox`/`Container` structure; all three parents are already `width: double.infinity` bounded.
- Preserved `stats_small_card.dart`'s exact hardcoded `TextStyle` (`fontSize: 20`, color logic) verbatim per UI-SPEC guidance - only the overflow-handling params moved into `EllipsisTooltipText`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Regenerated missing `lib/l10n/app_localizations.dart`**
- **Found during:** Task 1 (`fvm flutter analyze` on `income_total_card.dart` / `stats_balance_card.dart`)
- **Issue:** The worktree's `lib/l10n/` directory only contained the `.arb` source files - the generated `app_localizations.dart` (and per-locale `app_localizations_*.dart`) were missing, causing `uri_does_not_exist` / `undefined_identifier` analyzer errors unrelated to this plan's edits. This is expected worktree setup fallout (generated files are gitignored, not a regression caused by this plan's changes).
- **Fix:** Ran `fvm flutter gen-l10n`, which regenerated the localization files from the existing `.arb` sources per `l10n.yaml`.
- **Files modified:** None tracked by git (generated files are gitignored, consistent with the rest of the repo's `.gitignore` policy for build artifacts).
- **Verification:** `fvm flutter analyze --no-fatal-infos` subsequently passed with 0 issues on both files.
- **Committed in:** N/A (generated file, gitignored, not part of any task commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Necessary to unblock analysis in a freshly-reset worktree; no production or test code was affected beyond what the plan specified.

## Issues Encountered
None beyond the l10n regeneration above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three "headline total, no layout wrapper" call sites now share the `EllipsisTooltipText` pattern established in Plan 15-01, matching the four call sites already handled by Plan 15-02's shared-widget refactor.
- Full `fvm flutter test` suite green (263 tests passed, 0 failures).
- `fvm flutter analyze --no-fatal-infos` reports exactly the pre-existing 3-issue baseline (`app_constants.dart:12`, `expenses_screen.dart:154`, `income_screen.dart:156`) - 0 new issues introduced.
- `annual_grouped_bar_chart.dart`'s 2 `formatCompact` call sites remain untouched (D-02/D-03 exemption, out of this plan's scope).
- No blockers for Plan 15-04 (parallel wave-2 plan, disjoint file set).

---
*Phase: 15-amount-display-policy*
*Completed: 2026-09-01*

## Self-Check: PASSED

All 5 modified files and the SUMMARY.md itself confirmed present on disk; all 4 commits (`63a2537`, `6f4844f`, `6ce82ed`, `92618d5`) confirmed present in `git log`.
