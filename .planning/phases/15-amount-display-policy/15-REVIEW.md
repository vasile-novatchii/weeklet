---
phase: 15-amount-display-policy
reviewed: 2026-09-01T15:16:08Z
depth: standard
files_reviewed: 18
files_reviewed_list:
  - lib/presentation/widgets/common/ellipsis_tooltip_text.dart
  - test/presentation/widgets/common/ellipsis_tooltip_text_test.dart
  - lib/presentation/widgets/common/expense_amount_text.dart
  - lib/presentation/widgets/common/week_total_row.dart
  - lib/presentation/screens/expenses/widgets/list/expense_item_view.dart
  - lib/presentation/screens/income/widgets/list/income_item_view.dart
  - lib/presentation/screens/expenses/widgets/list/expense_week_group_view.dart
  - lib/presentation/screens/income/widgets/list/income_week_group_view.dart
  - test/integration/expense_crud_flow_test.dart
  - lib/presentation/screens/income/widgets/income_total_card.dart
  - lib/presentation/screens/stats/widgets/stats_summary_cards/stats_balance_card.dart
  - lib/presentation/screens/stats/widgets/stats_summary_cards/stats_small_card.dart
  - test/integration/income_crud_flow_test.dart
  - test/integration/stats_refresh_flow_test.dart
  - lib/presentation/screens/stats/widgets/category_details_list/category_details_item.dart
  - lib/presentation/screens/stats/widgets/monthly_item/monthly_bar_row.dart
  - lib/presentation/screens/stats/widgets/monthly_item/monthly_item.dart
  - lib/presentation/screens/stats/widgets/modern_donut_chart.dart
findings:
  critical: 1
  warning: 3
  info: 2
  total: 6
status: clean
fixed:
  - CR-01
---

## Post-Review Fix

**CR-01 fixed** (commit `0ef356b`): wrapped the amount in `Flexible` at all three
call sites (`expense_item_view.dart`, `income_item_view.dart`,
`category_details_item.dart`), matching the pattern already used for
`WeekTotalRow`/`MonthlyBarRow`/`MonthlyItem`. Added
`test/presentation/screens/list_row_amount_overflow_test.dart` (addresses
WR-01 for these three call sites) — confirmed it fails without the fix
(reproduces the exact `RenderFlex overflowed` error) and passes with it.
Full suite: 266/266 passing. Analyzer: 3 pre-existing baseline issues only.

WR-02 (negative-balance sign/color gap), WR-03 (dark-mode tooltip test
substance), IN-01/IN-02 (pre-existing non-localized strings) remain open as
documented follow-ups — all pre-existing, out of this phase's scope per
`15-UI-SPEC.md`'s D-01 lock on `NumberFormatter`.

# Phase 15: Code Review Report

**Reviewed:** 2026-09-01T15:16:08Z
**Depth:** standard
**Files Reviewed:** 18
**Status:** issues_found

## Summary

Reviewed the 15-amount-display-policy diff (`git diff d7a8cfc..HEAD`) against `15-UI-SPEC.md`.
Every formatter swap (`formatCompact*` -> `formatCurrency*`) and every `EllipsisTooltipText`/`Flexible` wiring instruction in the spec's "Phase Interaction Contracts" table was implemented at the literal line level exactly as prescribed - all 11 call sites, `flutter analyze` is clean, and the full suite (263 tests, including the 4 new `EllipsisTooltipText` tests and the 3 rewritten integration flows) passes.

However, the UI-SPEC's own layout reasoning for 3 of the 11 call sites ("Layout wrapper: none needed... the description column already absorbs all pressure") is factually wrong for Flutter's `RenderFlex`, and the executor implemented that flawed reasoning literally instead of verifying it.
I reproduced the resulting defect empirically with widget tests (see CR-01): `ExpenseAmountText` (used unwrapped in `expense_item_view.dart` and `income_item_view.dart`) and the unwrapped `EllipsisTooltipText` in `category_details_item.dart` do **not** ellipsis-trim when they don't fit - they trigger a hard `RenderFlex overflowed` layout error instead, which is precisely the failure mode FMT-02 exists to prevent.
This is the same "no flex sibling => Flutter gives every non-flex child of a Row an *unbounded* main-axis constraint" pitfall that the spec correctly identified and fixed for `monthly_bar_row.dart`, `monthly_item.dart`, and `week_total_row.dart` (items 2/5/8/9) - it just wasn't applied consistently to items 1/4/6.

Two lower-severity, pre-existing (not introduced by this diff) issues were also found in the touched files: a negative-sign display gap in the balance call sites, and several hardcoded non-localized English strings.

## Critical Issues

### CR-01: `EllipsisTooltipText` does not actually protect against overflow in 3 of the 11 call sites - FMT-02 guarantee is broken for large amounts

**Files:**
- `lib/presentation/widgets/common/expense_amount_text.dart:20-26` (consumed unwrapped by `expense_item_view.dart:115-118` and `income_item_view.dart:116-119`)
- `lib/presentation/screens/stats/widgets/category_details_list/category_details_item.dart:46-52`

**Issue:**
`Flutter`'s `RenderFlex` gives every **non-flex** child of a `Row` an unbounded main-axis constraint (`maxWidth: double.infinity`) as soon as the child has `flex == 0` - this happens *regardless* of whether another sibling is wrapped in `Expanded`/`Flexible`. An `Expanded` sibling only guarantees that *its own* content shrinks/wraps to make room; it does not retroactively bound the width of the other, non-flex siblings. So `maxLines: 1` + `overflow: TextOverflow.ellipsis` on `EllipsisTooltipText`'s inner `Text` is a no-op at these 3 sites: the text lays out at its full, unclipped natural width, and once that exceeds the remaining row space, Flutter raises "A RenderFlex overflowed by N pixels" instead of trimming to an ellipsis.

The UI-SPEC's own item 1 and item 6 entries claim "Layout wrapper: none needed... the description column already absorbs all pressure" - this reasoning is incorrect (see reproduction below), and the executor followed it without verifying against a real overflow scenario, even though the *same* Row-without-a-flex-sibling-on-the-amount pattern was correctly identified and fixed with `Flexible` at items 2, 5, 8, and 9.

**Reproduction (empirical, via `flutter test` against the actual production widgets - files were deleted after verification, not committed):**

1. `ExpenseItemView` at a real 375-logical-pixel phone width (iPhone-class device) with `Expense(amount: 1234567.89, description: 'Weekly groceries', ...)` and a short category name:
   ```
   A RenderFlex overflowed by 1.00 pixels on the right.
   ```
2. `IncomeItemView` at the same 375px width with `Income(amount: 1234567.89, description: 'Freelance payment', ...)`:
   ```
   A RenderFlex overflowed by 18 pixels on the right.
   ```
3. A minimal repro - `Row(children: [Expanded(Text('x')), ExpenseAmountText(formattedAmount: '1,234,567.89 MDL')])` at 200px width:
   ```
   A RenderFlex overflowed by 64 pixels on the right.
   ```
4. `CategoryDetailsItem` exhibits the identical root cause, but needs a much larger `totalAmount` (only overflowed once I used amounts around `1e14`+ at 320px width with a short category name) to trigger, because `bodyMedium` (14px) plus a short fixed-width leading dot leaves far more slack than the 16px `bodyLarge` list-row layout. Realistic multi-year aggregate category totals (up to `999,999,999.99`) did **not** overflow in testing - the risk here is real but low-probability given plausible personal-finance totals.

Items 1 and 4 break at a **7-digit currency amount** (`1,234,567.89`), which is not an extreme edge case for a finance app that just removed K-notation specifically so full precision is always visible - a car purchase, a down payment, or a business expense entered in a currency with a small denomination (MDL, RON, etc.) plausibly crosses this threshold. In debug builds this renders the classic yellow/black hazard-stripe overflow banner over the list row; in release builds `RenderFlex` clips the overflowing content, which for a trailing non-flex child means the amount is abruptly cut off (not ellipsis-trimmed) and can visually collide with the `CommonMenuButton` that follows it in the `Row`.

**Fix:** wrap the amount in `Flexible` at the two call sites (matching the pattern already used correctly for `WeekTotalRow`, `MonthlyBarRow`, and `MonthlyItem`), and likewise in `category_details_item.dart` for consistency/defense-in-depth:

```dart
// expense_item_view.dart and income_item_view.dart
Flexible(
  child: ExpenseAmountText(
    formattedAmount: formattedAmount,
    isIncome: isIncome,
  ),
),
```

```dart
// category_details_item.dart
Flexible(
  child: EllipsisTooltipText(
    text: NumberFormatter.formatCurrency(stat.totalAmount, currencySymbol),
    style: context.bodyMedium,
  ),
),
```

Note `Flexible` (not `Expanded`) to preserve the existing "amount only takes as much space as it needs, ellipsis-trims past that" behavior rather than stretching it.

## Warnings

### WR-01: No test guards the exact failure mode this phase exists to prevent

**Files:** `test/presentation/widgets/common/ellipsis_tooltip_text_test.dart`, plus the absence of any widget test for `expense_item_view.dart`, `income_item_view.dart`, or `category_details_item.dart`.

**Issue:** The only test coverage added for `EllipsisTooltipText` verifies its *own* config (`maxLines`, `overflow`, `softWrap`, `Tooltip.message`) in isolation, at an unconstrained width. None of the 11 integration points has a widget test that pumps the widget at a **narrow, bounded width with a long/large value** and asserts `tester.takeException()` is `null` (no `RenderFlex overflowed`). This is exactly the scenario CR-01 needed a throwaway test to catch - the regression guardrail in `15-UI-SPEC.md` ("ellipsis-trim when it does not fit") is asserted by the spec but never actually exercised by any test in the suite for the item-1/4/6 call sites.

**Fix:** Add at least one `testWidgets` per call site (or one parameterized helper reused across the 11) that pumps the widget inside a narrow `SizedBox` with a deliberately long formatted string and asserts `tester.takeException()` is `null`. This is the kind of test that would have caught CR-01 before merge.

### WR-02: Negative balances render with no sign and, in one case, no color cue - pre-existing, but touches call sites this phase modified

**Files:**
- `lib/presentation/screens/stats/widgets/stats_summary_cards/stats_balance_card.dart:52-62` (item 10, `formatCurrencyWithSign(balance, currencySymbol, isIncome: balance >= 0)`)
- `lib/presentation/screens/stats/widgets/monthly_item/monthly_item.dart:27-30` (item 9, `formatCurrency(snapshot.balance, currencySymbol)`)

**Issue:** `NumberFormatter.formatCurrencyWithSign`/`formatCurrency` both call `.abs()` on the amount and only ever prepend `+` (never `-`). For `StatsBalanceCard`, `isIncome: balance >= 0` means a negative balance renders identically to a positive balance of the same magnitude (`"204.50 MDL"` either way) - the card's text color is always hardcoded white, so there is **zero** visual indication the balance is negative. `MonthlyItem` at least colors the text red via `MonthlySnapshotUtils.isBalancePositive`, but the number itself still carries no sign. This directly undermines the app's stated core value ("Users can always see where their money went... accurate totals").

This is pre-existing behavior (unchanged by this diff - confirmed via `git diff d7a8cfc..HEAD`, `git log -S"isIncome: balance >= 0"` traces to a much earlier commit) and `15-UI-SPEC.md` explicitly locks `formatCurrency`/`formatCurrencyWithSign` as "already correct (D-01) - do not modify," so it is out of this phase's fix boundary. Flagging because it was encountered directly in files under review and is a real, provable financial-correctness bug worth a follow-up task.

**Fix (future task, not this phase):** either have `NumberFormatter` emit a `-` prefix for negative amounts regardless of `isIncome`, or have `StatsBalanceCard` pick text color based on sign (matching `MonthlyItem`'s pattern) so at minimum there's one visual cue.

### WR-03: Dark-mode regression guardrail is only nominally tested, not substantively verified

**File:** `test/presentation/widgets/common/ellipsis_tooltip_text_test.dart:62-77`

**Issue:** `15-UI-SPEC.md`'s Regression Guardrails section explicitly calls out: "Dark mode must be verified for the Tooltip bubble at least once (white-on-black bubble in dark mode vs. dark-grey-on-white in light mode)." The corresponding test (`'keeps the same Text contract and a single Tooltip under a dark theme'`) only asserts `find.byType(Tooltip)` exists and re-checks `maxLines`/`overflow`/`softWrap` on the inner `Text` - none of which differs between light and dark theme in the first place (those properties are set unconditionally by `EllipsisTooltipText.build()`, independent of `Theme.of(context).brightness`). It never inspects the `Tooltip`'s rendered decoration/text color, so it would not fail if a future `ThemeData` change broke the dark-mode tooltip bubble contrast. The guardrail is checked off in spirit but not in substance.

**Fix:** Either accept this as sufficient (the properties tested genuinely are theme-independent, so there is nothing theme-specific to assert about `EllipsisTooltipText` itself - the actual bubble color is Material's own `TooltipTheme` default, which this phase correctly does not override), or strengthen the test to pump `Tooltip.of(...)`/inspect the overlay's `_TooltipOverlay` decoration if real per-brightness verification is desired. Given `EllipsisTooltipText` deliberately does not touch `TooltipThemeData`, the current test may be an acceptable proxy - documenting for awareness rather than blocking.

## Info

### IN-01: Several hardcoded, non-localized English strings remain in files touched by this phase (pre-existing, not introduced by this diff)

**Files:**
- `lib/presentation/widgets/common/week_total_row.dart:21` - `'Total week'`
- `lib/presentation/screens/stats/widgets/modern_donut_chart.dart:45` - `'Spending by Category'`
- `lib/presentation/screens/stats/widgets/modern_donut_chart.dart:92` - `'Total'`

**Issue:** These files use `AppLocalizations`/`l10n.*` for other adjacent strings in the same widget tree (e.g. edit/delete menu labels, `l10n.statsAnnualBalance`), but these three labels are still inline English literals. Confirmed via `git log -S` that none of these three lines were touched by the phase-15 diff - purely pre-existing debt, surfaced here only because the files were in scope for this review.

**Fix:** Add ARB keys and route through `AppLocalizations` in a future localization-completeness pass; out of scope for this phase's formatting/truncation mandate.

### IN-02: `Category` fallback name `'Unknown'` and `Income` placeholder text hardcoded (pre-existing)

**Files:**
- `lib/presentation/screens/expenses/widgets/list/expense_item_view.dart:111` - `category?.name ?? 'Unknown'`
- `lib/presentation/screens/income/widgets/list/income_item_view.dart:111-112` - `'Income'` used both as a description fallback and as a fixed `categoryName`

**Issue:** Same non-localized-string pattern as IN-01, pre-existing and untouched by this diff (confirmed via `git diff d7a8cfc..HEAD`). Noted for completeness since these lines sit immediately next to the lines this phase did modify (the `formattedAmount` computation two lines above).

**Fix:** Same as IN-01 - future localization pass, not this phase's scope.

---

_Reviewed: 2026-09-01T15:16:08Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
