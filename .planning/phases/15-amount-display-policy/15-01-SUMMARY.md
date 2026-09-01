---
phase: 15-amount-display-policy
plan: 01
subsystem: ui
tags: [flutter, widgets, tooltip, ellipsis, formatting]

# Dependency graph
requires: []
provides:
  - "EllipsisTooltipText - the single shared FMT-02 primitive (ellipsis-trim + long-press tooltip) for all 11 amount-display integration points in Phase 15"
  - "ExpenseAmountText and WeekTotalRow refactored to render through EllipsisTooltipText, covering integration points 1, 2, 4, 5"
affects: [15-02, 15-03, 15-04]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "EllipsisTooltipText(text, style) - Tooltip(message: text) wrapping Text(maxLines:1, overflow:ellipsis, softWrap:false); no LayoutBuilder/TextPainter, tooltip attached unconditionally"
    - "Amount-side-only Flexible wrapping in Row(mainAxisAlignment: spaceBetween) layouts, leaving short fixed-string labels unwrapped"

key-files:
  created:
    - lib/presentation/widgets/common/ellipsis_tooltip_text.dart
    - test/presentation/widgets/common/ellipsis_tooltip_text_test.dart
  modified:
    - lib/presentation/widgets/common/expense_amount_text.dart
    - lib/presentation/widgets/common/week_total_row.dart

key-decisions:
  - "Centralized FMT-02 into one shared widget (EllipsisTooltipText) rather than 11 ad hoc Tooltip/overflow wirings, per 15-UI-SPEC.md's Centralization decision"
  - "Worktree branch was mis-created from the repo's root commit instead of dev's tip; reset to dev tip since the branch had zero unique commits at that point (safe, non-destructive)"
  - "EllipsisTooltipText's widget test pumps via a bare MaterialApp (matching amount_field_view_test.dart) instead of the shared pumpApp helper, because pumpApp's providers defaults to const [] and MultiBlocProvider -> MultiProvider asserts children.isNotEmpty (package:nested), crashing on an empty list - a pre-existing gap in test/helpers/test_app.dart left unfixed as out of this plan's scope"

patterns-established:
  - "EllipsisTooltipText: the single mechanism every Phase 15 amount call site routes through (directly or via ExpenseAmountText/WeekTotalRow)"

requirements-completed: [FMT-02]

# Metrics
duration: 10min
completed: 2026-09-01
---

# Phase 15 Plan 01: Shared EllipsisTooltipText widget Summary

**Created the single shared `EllipsisTooltipText` widget (Tooltip + ellipsis-trimmed Text) implementing FMT-02, and routed `ExpenseAmountText`/`WeekTotalRow` through it, covering 5 of the 11 Phase 15 amount-display integration points.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-09-01T14:32:44Z
- **Completed:** 2026-09-01T14:42:57Z
- **Tasks:** 2 completed
- **Files modified:** 4 (2 created, 2 modified)

## Accomplishments
- `EllipsisTooltipText` exists exactly per `15-UI-SPEC.md` section 0's contract: `Tooltip(message: text)` wrapping `Text(text, style, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false)` - no `triggerMode`, `decoration`, or `textStyle` override
- Its widget test covers exact-text render, `Tooltip.message == text`, the three-property `Text` contract, and a dedicated dark-theme regression case (4/4 passing)
- `ExpenseAmountText` (used by `expense_item_view.dart` and `income_item_view.dart`) now renders through `EllipsisTooltipText` with its existing style/color logic untouched
- `WeekTotalRow` (used by `expense_week_group_view.dart` and `income_week_group_view.dart`) now wraps its amount side in `Flexible(EllipsisTooltipText(...))`, leaving the `'Total week'` label unwrapped
- Full test suite: 263/263 passing (259 baseline + 4 new) - zero regressions
- Analyzer: exactly the 3 pre-existing baseline infos, 0 new issues

## Task Commits

Task 1 followed the TDD RED -> GREEN cycle (two commits); Task 2 is a single commit.

1. **Task 1 (RED): failing test for EllipsisTooltipText** - `07744cb` (test)
2. **Task 1 (GREEN): EllipsisTooltipText widget + test fix** - `a781ba9` (feat)
3. **Task 2: route ExpenseAmountText/WeekTotalRow through EllipsisTooltipText** - `51049d4` (feat)

**Plan metadata:** committed alongside this SUMMARY.

## Files Created/Modified
- `lib/presentation/widgets/common/ellipsis_tooltip_text.dart` - new shared widget: `Tooltip` + single-line ellipsis `Text`
- `test/presentation/widgets/common/ellipsis_tooltip_text_test.dart` - 4 widget tests (render, tooltip message, text contract, dark theme)
- `lib/presentation/widgets/common/expense_amount_text.dart` - bare `Text` replaced with `EllipsisTooltipText`, same color/style logic
- `lib/presentation/widgets/common/week_total_row.dart` - amount `Text` replaced with `Flexible(EllipsisTooltipText(...))`, label left unwrapped

## Decisions Made
- Centralization: every one of Phase 15's 11 integration points routes through `EllipsisTooltipText`, directly or via `ExpenseAmountText`/`WeekTotalRow` - matches `15-UI-SPEC.md`'s Centralization decision and this project's existing DRY conventions (`NumberFormatter`, `ExpenseAmountText`).
- No `NumberFormatter` call sites were touched in this plan (that is Plan 15-02's scope, per the plan's objective).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Worktree branch mis-created from the repo's root commit**
- **Found during:** Setup, before Task 1
- **Issue:** This worktree's branch (`worktree-agent-af1842a8b7fb87bb9`) was created at `e11eacc` ("init proj", the repository's very first commit) rather than `dev`'s tip (`d7a8cfc`). The entire `lib/presentation`, `lib/domain`, `test/` trees (421 files, 45K+ lines) plus `.planning/phases/15-amount-display-policy/` were absent, making the plan's files unmodifiable and its context files unreadable in-worktree.
- **Fix:** Verified the branch had zero unique commits (it was an unmodified ancestor of `dev`), then ran `git reset --hard dev` to fast-forward it to `dev`'s tip. Non-destructive - no work existed on the branch to lose. `.planning/` (gitignored) was separately copied from the main checkout onto local disk so plan/context files could be read before the reset; this copy has no effect on git history.
- **Files modified:** none (branch-pointer fix only)
- **Verification:** `git log --oneline -3` showed the branch at `d7a8cfc` with full `lib/`/`test/` trees present afterward.
- **Committed in:** n/a (no commit - branch reset, not a content change)

**2. [Rule 3 - Blocking] Missing generated l10n files**
- **Found during:** Task 1, first test run (RED phase)
- **Issue:** `lib/l10n/app_localizations*.dart` are gitignored generated files (per `STATE.md`'s 14-05 note) and were absent from this freshly-reset worktree, so any test importing `test/helpers/test_app.dart` failed to compile with `Undefined name 'AppLocalizations'`.
- **Fix:** Ran `fvm flutter pub get`, which triggers `gen-l10n` automatically from the ARB sources already present in `lib/l10n/*.arb`.
- **Files modified:** none tracked (generated files stay gitignored)
- **Verification:** `ls lib/l10n` showed `app_localizations.dart` + per-locale files present; subsequent test runs compiled.
- **Committed in:** n/a (generated files are gitignored, not committed)

**3. [Rule 1 - Bug] Shared `pumpApp` test helper crashes with the documented empty-providers default**
- **Found during:** Task 1, first real test run after the RED commit
- **Issue:** `test/helpers/test_app.dart`'s `pumpApp` docstring states `providers` "can be omitted (defaults to `const []`)" for widgets that read no BLoC state. In practice, `MultiBlocProvider` extends `MultiProvider`, whose `nested` package dependency asserts `children.isNotEmpty` - passing an empty `providers` list crashes every test with `'children.isNotEmpty': is not true`, regardless of the `theme:` parameter. No existing test in the codebase actually calls `pumpApp` with an empty/omitted `providers` list, so this pre-existing gap had never been exercised.
- **Fix:** Rather than modifying the shared `test_app.dart` helper (out of this plan's `files_modified` scope, and a fix there could affect every other test file), routed `ellipsis_tooltip_text_test.dart` around it: added a local `pumpText` helper that pumps a bare `MaterialApp` with `AppLocalizations` delegates directly, matching the already-established `test/presentation/widgets/common/form/amount_field_view_test.dart` pattern (also cited in this plan's `read_first`) for widgets with no BLoC dependency.
- **Files modified:** `test/presentation/widgets/common/ellipsis_tooltip_text_test.dart` (this plan's own test file - no scope creep)
- **Verification:** all 4 tests pass (light + dark theme cases)
- **Committed in:** `a781ba9` (Task 1 GREEN commit)

---

**Total deviations:** 3 auto-fixed (2 blocking setup issues, 1 pre-existing test-helper bug worked around locally)
**Impact on plan:** All three were prerequisites for executing the plan at all (worktree/l10n) or were resolved without touching any file outside this plan's declared scope (test helper workaround, isolated to this plan's own test file). No scope creep into Plan 15-02/15-03/15-04's territory.

## Issues Encountered
None beyond the deviations documented above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `EllipsisTooltipText` is ready for direct import by Plans 15-03 and 15-04, which wire the remaining 6 integration points (`income_total_card.dart`, `category_details_item.dart`, `modern_donut_chart.dart`, `monthly_bar_row.dart`, `monthly_item.dart`, `stats_balance_card.dart`, `stats_small_card.dart`).
- Plan 15-02 can now safely swap `formatCompact(WithSign)` -> `formatCurrency(WithSign)` at the call sites that consume `ExpenseAmountText`/`WeekTotalRow` (integration points 1, 2, 4, 5) without any further widget-level change.
- Known pre-existing gap in `test/helpers/test_app.dart` (empty-`providers` crash) remains unfixed - flagged here for visibility; a future quick task could relax the `pumpApp` contract to not require BLoC providers for provider-free widget tests.

---
*Phase: 15-amount-display-policy*
*Completed: 2026-09-01*

## Self-Check: PASSED

- FOUND: lib/presentation/widgets/common/ellipsis_tooltip_text.dart
- FOUND: test/presentation/widgets/common/ellipsis_tooltip_text_test.dart
- FOUND: lib/presentation/widgets/common/expense_amount_text.dart
- FOUND: lib/presentation/widgets/common/week_total_row.dart
- FOUND: commit 07744cb (test(15-01): add failing test for EllipsisTooltipText)
- FOUND: commit a781ba9 (feat(15-01): add shared EllipsisTooltipText widget)
- FOUND: commit 51049d4 (feat(15-01): route ExpenseAmountText and WeekTotalRow through EllipsisTooltipText)
