# Roadmap: Weeklet

## Milestones

- **[v1.0 - Shipped 2026-04-27](.planning/milestones/v1.0-ROADMAP.md)** - Architecture cleanup, income screen, statistics, settings, PDF export, release assets, integration gap closure (7 phases, 21 plans, 25/25 requirements)
- **[v1.1 - Shipped 2026-05-03](.planning/milestones/v1.1-ROADMAP.md)** - UX polish and full RO/RU/EN localization (2 phases, 12 plans, 6/6 requirements)
- **[v1.2 - Shipped 2026-07-26](.planning/milestones/v1.2-ROADMAP.md)** - Comprehensive test infrastructure and coverage; 0 → 169 tests across use cases, BLoCs, widgets, and integration flows (4 phases, 16 plans, 27/27 requirements)
- 🚧 **v1.3 E2E Polish - In progress** - Fix every bug and UX gap found during e2e testing: correct amount display, complete localization, reliable filters and exports (6 phases, 17 requirements)

---

## Phases

<details>
<summary>✅ v1.0 MVP (Phases 1–7) — SHIPPED 2026-04-27</summary>

See [v1.0-ROADMAP.md](.planning/milestones/v1.0-ROADMAP.md) for full details.

</details>

<details>
<summary>✅ v1.1 UX Polish (Phases 8–9) — SHIPPED 2026-05-03</summary>

- [x] Phase 8: UI Polish — formatCompact, scrollbars, 4-tab nav, PDF hide, empty state (6/6 plans) — completed 2026-04-30
- [x] Phase 9: Localization — gen-l10n, ARB files (EN/RO/RU), typed exceptions, full widget tree localization (6/6 plans) — completed 2026-05-03

See [v1.1-ROADMAP.md](.planning/milestones/v1.1-ROADMAP.md) for full details.

</details>

<details>
<summary>✅ v1.2 Testing (Phases 10–13) — SHIPPED 2026-07-26</summary>

- [x] Phase 10: Test Infrastructure & Use Case Tests — validation, delete, filter utils (3/3 plans) — completed 2026-05-21
- [x] Phase 11: BLoC State Machine Tests — all 6 BLoCs via bloc_test (3/3 plans) — completed 2026-05-21
- [x] Phase 12: Widget Component Tests — 5 screens + 2 form components (5/5 plans) — completed 2026-06-21
- [x] Phase 13: Integration & Critical Path Tests — 4 real-Hive E2E flows incl. byte-level PDF verification (5/5 plans) — completed 2026-07-14

See [v1.2-ROADMAP.md](.planning/milestones/v1.2-ROADMAP.md) for full details.

</details>

### 🚧 v1.3 E2E Polish (Phases 14-19) - In Progress

**Milestone Goal:** Fix every bug and UX gap found during end-to-end testing so the app is genuinely release-ready - correct amount display, complete localization, reliable filters and exports.

**Milestone-wide constraints:**
The 169-test suite must stay green after every phase; update assertions where behavior intentionally changes (e.g. amount formatting).
Every new user-facing string ships with EN/RO/RU ARB entries.

- [x] **Phase 14: Data Correctness Fixes** - Filters, charts, lists, and category creation always reflect the data the user actually entered
- [ ] **Phase 15: Amount Display Policy** - Full-format amounts app-wide, ellipsis-trim with long-press tooltip when they do not fit
- [ ] **Phase 16: Stats PDF Export** - Stats tab exports to PDF honoring the active filter, including all-months; export hidden when there is no data
- [ ] **Phase 17: Localization Completeness** - Language switch translates every remaining string and date format
- [ ] **Phase 18: Income & Home UX** - Inline income errors, filter-preserving pull-to-refresh, home income subtitle, contextual placeholders
- [ ] **Phase 19: Settings & System UI Polish** - Licenses page, reset-section spacing, bottom sheets above system navigation

## Phase Details

### Phase 14: Data Correctness Fixes

**Goal**: Filters, charts, lists, and category creation always reflect the data the user actually entered
**Depends on**: Nothing (first phase of v1.3)
**Requirements**: INC-05, STATS-04, CAT-01, UX-08
**Success Criteria** (what must be TRUE):

  1. After adding an income entry for a different month/year than currently selected, the income screen filter switches to that entry's month and year and the new entry is visible
  2. The spending-by-category chart shows every category with spending in the selected period, including small amounts such as 23 MDL per year
  3. Creating a category during the first-expense flow (no categories exist yet) adds it without overwriting any previously created category
  4. The expenses list shows week groups newest-first with the current week always pinned at the top (e.g. current week 24 first, then 23, 22, ...)

**Plans**: 6 plans in 3 waves - 6/6 complete (all 4 requirements met: INC-05, STATS-04, CAT-01, UX-08)

Plans:
**Wave 1**

- [x] 14-01-PLAN.md - UX-08: shared ISO week keys (`WeekUtils.isoWeekOf`) plus pinned descending week ordering for expenses and income (wave 1)
- [x] 14-02-PLAN.md - STATS-04: 3% minimum donut slice, `<1%` badge, minimum category progress-bar fill (wave 1)
- [x] 14-03-PLAN.md - INC-05: focus-target reload so the income filter follows a newly added or edited entry (wave 1)
- [x] 14-04-PLAN.md - CAT-01: `default_category_id` marker plus `GetOrCreateDefaultCategoryUseCase` in the domain and data layers (wave 1)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 14-05-PLAN.md - CAT-01: localized `defaultCategoryName` and default resolution moved into `ExpenseBloc` (wave 2)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 14-06-PLAN.md - CAT-01: widget fallback deleted and mid-flow category auto-selected (wave 3)

**UI hint**: yes

### Phase 15: Amount Display Policy

**Goal**: Every amount in the app displays as a full precise value that fits its layout
**Depends on**: Nothing (independent; ordered after Phase 14 so correctness fixes land first)
**Requirements**: FMT-01, FMT-02
**Success Criteria** (what must be TRUE):

  1. All amounts app-wide - stats annual balance/expenses/income cards, income total, lists, home - display in full format such as 8570.8 MDL
  2. No compact K-notation appears anywhere in the app
  3. An amount too long for its row or card is ellipsis-trimmed instead of overflowing or wrapping
  4. Long-pressing a trimmed amount shows a tooltip with the full value

**Plans**: TBD
**UI hint**: yes

Note: this phase deliberately reverses the v1.1 "compact all amounts" decision (quick task 260430-qou).

### Phase 16: Stats PDF Export

**Goal**: Users can export the stats screen to PDF exactly as filtered, and export is only offered when there is data
**Depends on**: Phase 15 (exported amounts must follow the final display policy; byte-level PDF test assertions should only churn once)
**Requirements**: EXP-05, EXP-06
**Success Criteria** (what must be TRUE):

  1. User can export the stats tab to a PDF that reflects the active filter (selected year and month)
  2. With "all months" selected, the exported PDF includes every month with data for the selected year
  3. The export button is hidden whenever the current selection has no data to export

**Plans**: TBD
**UI hint**: yes

### Phase 17: Localization Completeness

**Goal**: Switching the app language translates every remaining piece of UI, including dates
**Depends on**: Phase 15 (touches the same stats and home widgets; avoids conflicting edits)
**Requirements**: LOC-02, LOC-03
**Success Criteria** (what must be TRUE):

  1. After switching language, filter month names display in the selected language
  2. The "Income vs Expenses" / "Income" / "Expenses" stats titles and the "Total week" / "Week #" home labels display in the selected language
  3. Date inputs show translated month names for RO/RU (e.g. "3 iunie, 2022")
  4. Date inputs use the UK date format when the app language is EN

**Plans**: TBD
**UI hint**: yes

### Phase 18: Income & Home UX

**Goal**: Income entry gives immediate inline feedback, and the home screen surfaces income context without losing filter state
**Depends on**: Phase 14 (INC-05 changes the income filter behavior that pull-to-refresh must preserve)
**Requirements**: INC-06, INC-07, UX-06, UX-07
**Success Criteria** (what must be TRUE):

  1. When adding income fails, the modal stays open and shows the error inline - below the input for field errors, as a general message otherwise
  2. Pull-to-refresh on the income screen reloads all data while the active year/month filter stays selected
  3. The home screen shows a subtitle under the Expenses title with total income for the selected month/year, and hides it when no income exists for that period
  4. Description inputs show a placeholder appropriate to the screen using them

**Plans**: TBD
**UI hint**: yes

### Phase 19: Settings & System UI Polish

**Goal**: Settings and system-level chrome feel complete and native on both platforms
**Depends on**: Nothing (independent polish)
**Requirements**: SET-06, SET-07, UX-09
**Success Criteria** (what must be TRUE):

  1. Tapping the app version card in settings opens Flutter's built-in licenses page
  2. The "Reset all data" section has comfortable spacing at the bottom of the settings screen
  3. Bottom sheets render above the Android/iOS system navigation bar

**Plans**: TBD
**UI hint**: yes

---

## Progress

**Execution Order:**
Phases execute in numeric order: 14 → 15 → 16 → 17 → 18 → 19

| Phase | Milestone | Plans | Status   | Completed  |
|-------|-----------|-------|----------|------------|
| 1–7   | v1.0      | 21/21 | Complete | 2026-04-27 |
| 8     | v1.1      | 6/6   | Complete | 2026-04-30 |
| 9     | v1.1      | 6/6   | Complete | 2026-05-03 |
| 10    | v1.2      | 3/3   | Complete | 2026-05-21 |
| 11    | v1.2      | 3/3   | Complete | 2026-05-21 |
| 12    | v1.2      | 5/5   | Complete | 2026-06-21 |
| 13    | v1.2      | 5/5   | Complete | 2026-07-14 |
| 14. Data Correctness Fixes | v1.3 | 6/6 | Complete | 2026-08-23 |
| 15. Amount Display Policy | v1.3 | 0/? | Not started | - |
| 16. Stats PDF Export | v1.3 | 0/? | Not started | - |
| 17. Localization Completeness | v1.3 | 0/? | Not started | - |
| 18. Income & Home UX | v1.3 | 0/? | Not started | - |
| 19. Settings & System UI Polish | v1.3 | 0/? | Not started | - |
