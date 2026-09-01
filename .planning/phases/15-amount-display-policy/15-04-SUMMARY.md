---
phase: 15-amount-display-policy
plan: 04
subsystem: ui
tags: [flutter, widgets, tooltip, ellipsis, formatting, stats]

# Dependency graph
requires:
  - phase: 15-amount-display-policy
    provides: "EllipsisTooltipText shared widget (15-01)"
provides:
  - "Full-format (formatCurrency) amounts at the four remaining stats-breakdown call sites: category_details_item.dart, monthly_bar_row.dart, monthly_item.dart, modern_donut_chart.dart"
  - "All 11 Phase 15 integration points now route through EllipsisTooltipText - phase-wide FMT-01/FMT-02 coverage complete except the deliberate annual_grouped_bar_chart.dart exemption (D-02/D-03)"
affects: [16, 17]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "SizedBox(width: 140) donut-hole-diameter cap for a Stack child with no other width constraint (new axis use of an existing SizedBox idiom in this file)"

key-files:
  created: []
  modified:
    - lib/presentation/screens/stats/widgets/category_details_list/category_details_item.dart
    - lib/presentation/screens/stats/widgets/monthly_item/monthly_bar_row.dart
    - lib/presentation/screens/stats/widgets/monthly_item/monthly_item.dart
    - lib/presentation/screens/stats/widgets/modern_donut_chart.dart

key-decisions:
  - "Worktree branch was mis-created from the repo's root commit ('init proj') instead of dev's tip; reset to dev tip since the branch had zero unique commits (safe, non-destructive) - same recurring setup issue as 15-01/15-02/15-03"
  - "Split the SizedBox(width: 140) explanatory comment onto two lines above the width: property (rather than a same-line trailing comment) to stay within the project's 80-char line width after dart format"

patterns-established: []

requirements-completed: [FMT-01, FMT-02]

# Metrics
duration: ~10min
completed: 2026-09-01
---

# Phase 15 Plan 04: Stats Breakdown Full-Format + Ellipsis/Tooltip Summary

**Full-formatted and wired `EllipsisTooltipText` into the last four stats-screen amount call sites - per-category list amount, monthly income/expense bar rows, per-month balance header, and the donut chart's center Total (new `SizedBox(width: 140)` cap) - leaving `annual_grouped_bar_chart.dart`'s K-notation exemption untouched.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-09-01T14:48:00Z (approx, after worktree setup)
- **Completed:** 2026-09-01T14:58:19Z
- **Tasks:** 3 completed
- **Files modified:** 4

## Accomplishments
- `category_details_item.dart`'s per-category amount now renders `NumberFormatter.formatCurrency` through `EllipsisTooltipText`, no layout wrapper needed (the `Expanded` category-name sibling already absorbs `Row` pressure)
- `monthly_bar_row.dart` and `monthly_item.dart` both switched `formatCompact` -> `formatCurrency` and wrapped their amount `Text` in `Flexible(EllipsisTooltipText(...))`, matching the `WeekTotalRow` fix pattern from Plan 15-01; labels (`label`, `monthName`) stay unwrapped
- `modern_donut_chart.dart`'s center "Total" now renders full-format through `EllipsisTooltipText`, bounded to a new `SizedBox(width: 140)` (== `centerSpaceRadius * 2`, the donut hole's diameter) - the one genuinely novel layout requirement in Phase 15 (D-05/D-06); no `FittedBox`/`AutoSizeText` added
- `annual_grouped_bar_chart.dart` received zero edits (`git diff --stat` confirms no output) - the D-02/D-03 K-notation exemption survives intact
- Full test suite: 263/263 passing, zero regressions
- Analyzer: exactly the pre-existing 3-issue baseline (`app_constants.dart:12`, `expenses_screen.dart:154`, `income_screen.dart:156`), 0 new issues

## Task Commits

1. **Task 1: Full-format and wrap category_details_item.dart** - `6f14b9e` (feat)
2. **Task 2: Full-format and Flexible-wrap monthly_bar_row.dart and monthly_item.dart** - `036ab7c` (feat)
3. **Task 3: Full-format and width-cap the donut chart's center Total** - `291e68f` (feat)

**Plan metadata:** committed alongside this SUMMARY.

## Files Created/Modified
- `lib/presentation/screens/stats/widgets/category_details_list/category_details_item.dart` - `formatCompact` -> `formatCurrency`; amount `Text` -> `EllipsisTooltipText`
- `lib/presentation/screens/stats/widgets/monthly_item/monthly_bar_row.dart` - `formatCompact` -> `formatCurrency`; amount `Text` -> `Flexible(EllipsisTooltipText(...))`
- `lib/presentation/screens/stats/widgets/monthly_item/monthly_item.dart` - `formatCompact` -> `formatCurrency`; balance `Text` -> `Flexible(EllipsisTooltipText(...))`
- `lib/presentation/screens/stats/widgets/modern_donut_chart.dart` - `formatCompact` -> `formatCurrency`; center `Column` wrapped in `SizedBox(width: 140)`; amount `Text` -> `EllipsisTooltipText`

## Decisions Made
- No `NumberFormatter` class changes - `formatCurrency`/`formatCurrencyWithSign` were already correct (D-01); `formatCompact`/`formatCompactWithSign` kept as-is since `annual_grouped_bar_chart.dart` still uses both.
- `SizedBox(width: 140)` comment split across two lines above the `width:` property instead of a trailing same-line comment, to respect the project's 80-char line width after `dart format` (the plan's literal trailing-comment example would have exceeded 80 chars).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Worktree branch mis-created from the repo's root commit**
- **Found during:** Setup, before Task 1
- **Issue:** This worktree's branch (`worktree-agent-a9c96856f8b2e88b1`) was created at `e11eacc` ("init proj", the repository's very first commit) rather than `dev`'s tip (`ea40bc2`). The `lib/`, `test/` trees and `.planning/phases/15-amount-display-policy/` context files were absent or stale, making the plan's target files unmodifiable and its context unreadable in-worktree.
- **Fix:** Verified the branch had zero unique commits vs. `dev` (an unmodified ancestor), then ran `git reset --hard dev` to fast-forward it to `dev`'s tip. Non-destructive - no work existed on the branch to lose.
- **Files modified:** none (branch-pointer fix only)
- **Verification:** `git log --oneline -3` showed the branch at `ea40bc2` with `lib/presentation/widgets/common/ellipsis_tooltip_text.dart` (Plan 15-01's output) present afterward.
- **Committed in:** n/a (no commit - branch reset, not a content change)

**2. [Rule 3 - Blocking] Missing generated l10n files**
- **Found during:** Task 1, first test run
- **Issue:** `lib/l10n/app_localizations*.dart` are gitignored generated files and were absent from this freshly-reset worktree, causing every widget test that imports localization (including `stats_screen_test.dart`) to fail to compile with `Undefined name 'AppLocalizations'`.
- **Fix:** Ran `fvm flutter pub get`, which triggers `gen-l10n` from the ARB sources already present in `lib/l10n/*.arb`.
- **Files modified:** none tracked (generated files stay gitignored)
- **Verification:** `ls lib/l10n` showed `app_localizations.dart` + per-locale files present; `stats_screen_test.dart` compiled and passed afterward (9/9).
- **Committed in:** n/a (generated files are gitignored, not committed)

**3. [Rule 1 - Bug] Plan's literal SizedBox comment exceeded 80-char line width**
- **Found during:** Task 3, `dart format` pass
- **Issue:** The plan's exact suggested comment (`// == centerSpaceRadius * 2 (line 58) - the donut hole's diameter` as a trailing comment on the `width: 140,` line) produced a 96-character line, exceeding this project's enforced 80-char page width (`CLAUDE.md` Technology Stack: "Page width: 80 characters").
- **Fix:** Moved the comment above the `SizedBox(` and `width: 140,` lines, split across two lines, preserving the exact same informational content (the `centerSpaceRadius * 2` rationale) required by the plan's acceptance criteria.
- **Files modified:** `lib/presentation/screens/stats/widgets/modern_donut_chart.dart` (this task's own file - no scope creep)
- **Verification:** `awk 'length($0) > 80'` returned no lines after the fix; `fvm flutter analyze` still reports 0 issues for this file; `grep -c 'width: 140'` still returns 1 per acceptance criteria.
- **Committed in:** `291e68f` (Task 3 commit)

---

**Total deviations:** 3 auto-fixed (2 blocking setup issues, 1 minor formatting fix)
**Impact on plan:** All three were prerequisites for executing the plan at all (worktree/l10n) or were resolved within this task's own declared file scope (line-width fix). No scope creep into other plans' territory, no change to the plan's specified behavior or acceptance criteria.

## Issues Encountered
None beyond the deviations documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All 11 of Phase 15's `15-CONTEXT.md` Integration Points are now full-formatted and routed through `EllipsisTooltipText`, except the deliberately exempt `annual_grouped_bar_chart.dart` (D-02/D-03).
- Full test suite (263/263) and analyzer (3 pre-existing baseline issues, 0 new) confirm no regressions across the whole Phase 15 change set delivered by 15-01 through 15-04.
- No blockers for Phase 15 closeout or downstream Phases 16/17.

---
*Phase: 15-amount-display-policy*
*Completed: 2026-09-01*

## Self-Check: PASSED

- FOUND: lib/presentation/screens/stats/widgets/category_details_list/category_details_item.dart
- FOUND: lib/presentation/screens/stats/widgets/monthly_item/monthly_bar_row.dart
- FOUND: lib/presentation/screens/stats/widgets/monthly_item/monthly_item.dart
- FOUND: lib/presentation/screens/stats/widgets/modern_donut_chart.dart
- FOUND: commit 6f14b9e (feat(15-04): full-format and wrap category_details_item.dart)
- FOUND: commit 036ab7c (feat(15-04): full-format and Flexible-wrap monthly_bar_row.dart and monthly_item.dart)
- FOUND: commit 291e68f (feat(15-04): full-format and width-cap the donut chart's center Total)
