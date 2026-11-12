# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

---

## Milestone: v1.1 — UX Polish

**Shipped:** 2026-05-03
**Phases:** 2 (08, 09) | **Plans:** 12 | **Sessions:** 3

### What Was Built

- **Phase 8 — UI Polish:** `formatCompact` (K-notation for amounts ≥ 1000), global `ScrollConfiguration` injection, 4-tab bottom navigation (Categories moved to AppBar icon), expenses empty state centering, PDF export hidden when list is empty, compact stats amounts.
- **Phase 9 — Localization:** `gen-l10n` infrastructure with `l10n.yaml` and 3 ARB files (145 keys × EN/RO/RU), trimmed `LocaleManager`, `localeResolutionCallback` English fallback, typed domain exceptions replacing all English error strings in the domain layer, full widget tree localization across 60+ files.

### What Worked

- **Parallel worktree execution:** Plans 09-03 and 09-04 ran in parallel worktrees without conflicts — they touched entirely different file sets. The post-merge gate caught the one overlap (`amount_field_view.dart`) cleanly.
- **TDD RED→GREEN discipline for Phase 9:** Wave 0 committed failing tests before implementation; all three test files turned GREEN exactly as planned.
- **Typed exception pattern:** Replacing use-case `ArgumentError`/English strings with enum-coded exceptions made the BLoC→widget translation switch clean and testable.
- **ARB parity enforced by automation:** Python parity check in plan 09-05 caught missing keys before human review.

### What Was Inefficient

- **Agent stream timeout (09-03):** The 09-03 executor stalled on the stream watchdog after committing expenses files but before completing categories and settings. Recovery required manually merging the worktree, resolving a conflict in `amount_field_view.dart`, and committing the leftover category files separately — ~30 min of cleanup.
- **09-04 agent committed to main branch directly:** The 09-04 agent bypassed its worktree and committed directly to `dev`. This created an unusual state where one worktree had uncommitted but valid changes while its worktree branch was at base. Root cause unclear (likely worktree lock during sequential dispatch).
- **REQUIREMENTS.md checkboxes not auto-ticked:** The SDK marks phases complete but leaves `REQUIREMENTS.md` checkbox state unchanged. Required manual tick at milestone close.

### Patterns Established

- **BLoC emits error codes, widgets translate:** `actionError` carries ARB key names (e.g., `'errorBiometricFailed'`), never English sentences. Widget listeners use a `switch` to call `l10n.{key}`.
- **Bare `Locale` objects (no country codes):** `LocaleManager.supportedLocales` and all persisted locales use `Locale('en')` not `Locale('en', 'US')`. `Locale.==` requires exact match — country codes cause silent UI bugs (CR-01).
- **Required button labels in dialogs:** `CustomConfirmationDialog` `confirmButtonText`/`cancelButtonText` are `required` — callers must pass l10n strings. No English defaults.
- **`currencySymbol` passed explicitly:** `AmountFieldView` takes `required this.currencySymbol`. Forces all call sites to be intentional about the currency label shown.

### Key Lessons

1. **Stream watchdog timeouts are recoverable.** When an agent stalls mid-plan, check `git log` first — committed work is safe in the worktree. Run the merge manually, resolve conflicts, and commit leftover unstaged changes. Don't re-execute the full plan.
2. **Wave 2 parallel plans must have zero `files_modified` overlap.** The overlap check is critical — even a single shared file forces sequential execution. `amount_field_view.dart` was in both 09-03 and 09-04 plans but the overlap was caught at merge time, not planning time.
3. **Locale equality in Flutter is exact.** `Locale('en', 'US') != Locale('en')`. Use bare language codes everywhere — in `supportedLocales`, persisted state, and option lists.
4. **Code review found 2 critical bugs post-execution.** CR-01 (locale mismatch) and CR-02 (hardcoded English in BLoC) would have shipped to users without the review gate. The gsd-code-review step is worth keeping mandatory.

### Cost Observations

- Model: Claude Sonnet 4.6 (1M context) throughout
- Sessions: ~3 sessions across 4 days (limits hit during Phase 9 execution)
- Notable: 1M context window allowed rich prior-wave SUMMARY context to be passed to executor agents without trimming

---

## Milestone: v1.2 — Testing

**Shipped:** 2026-07-26
**Phases:** 4 (10–13) | **Plans:** 16 | **Sessions:** multiple across ~2 months

### What Was Built

- **Phase 10 — Use case tests:** validation (incl. TDD `CategoryValidationError.duplicateName` case-insensitive guard), delete success/not-found, year/month filter utils (TEST-01–08).
- **Phase 11 — BLoC tests:** all six BLoCs with `bloc_test`, shared `fake_blocs.dart`, per-test GetIt isolation for CRUD handlers that call `sl<StatsBloc>()` (TEST-09–15).
- **Phase 12 — Widget tests:** 5 screens + 2 form components via a shared `pumpApp` helper and mocktail BLoCs; all SettingsScreen toggles verified by real UI taps (TEST-16–23).
- **Phase 13 — Integration tests:** 4 real-Hive, widget-driven E2E flows (expense CRUD, income CRUD, stats refresh, PDF export) with byte-level PDF content verification via a hand-rolled extractor (TEST-24–27).

### What Worked

- **Real Hive over fakes for integration.** Phase 13 exercised the actual persistence + DI graph (harness mirrors `service_locator.dart` registration-for-registration), so integration tests proved real wiring instead of re-verifying BLoC logic already covered by unit tests.
- **Assert what the user sees.** CRUD flows driven by real widget taps (never direct BLoC dispatch, D-01) and stats proven via the visible Stats-tab balance (D-03) — tests survive internal refactors.
- **Independent verification paid off.** The Phase 13 verifier re-ran the full suite itself (169/169) rather than trusting SUMMARY narration, catching the premature `requirements-completed` marking in 13-01's frontmatter.
- **Equatable-aware seeding.** Repeated pattern across StatsBloc/SettingsBloc: seed with a *distinct* prior state so a no-op transition still emits — otherwise `bloc_test` sees `[]` and fails confusingly.

### What Was Inefficient

- **`TestWidgetsFlutterBinding` hangs on real `dart:io` Hive writes.** Root-causing why integration tests hung forever cost real time before landing on `LiveTestWidgetsFlutterBinding()` — a non-obvious requirement now documented as a project decision.
- **No pure-Dart PDF text extractor exists.** Had to hand-roll `extractPdfText` (zlib inflate + Tj/TJ regex) because no suitable FFI-free package is on pub.dev — worked, but was unplanned effort.
- **`const` churn in domain tests.** Multiple plans hit `const` compile errors (`DateTime` has no const constructor; `late` repository vars aren't const) — the planner's snippets used `const` liberally and each executor had to strip it.

### Patterns Established

- **Real-Hive test harness:** `test/helpers/test_hive_env.dart` provides `initTestDi()`/`teardownTestDi()` with a temp-dir Hive and full DI graph; the canonical way to write an integration test in this repo.
- **Platform fakes for file/share:** `_TestTempPathProvider implements PathProviderPlatform` + `FakeSharePlatform extends SharePlatform` avoid `MissingPluginException` in PDF export/share tests.
- **Concrete fake BLoCs for GetIt:** fakes must `extend` the concrete BLoC type (e.g. `FakeStatsBloc extends StatsBloc`) — not bare `Bloc<E,S>` — so `sl<ConcreteBloc>()` registrations resolve.

### Key Lessons

1. **The verifier must run the suite, not read the summary.** Independent re-execution is what separates "claimed done" from "done" — it caught a premature completion marking that source-of-truth checkboxes would have hidden.
2. **REQUIREMENTS.md checkbox drift persists across milestones.** As in v1.1, execution left 21/27 boxes unticked despite passing tests. The milestone audit + archive step is the reliable place to reconcile — don't trust checkbox state as coverage evidence.
3. **Process artifacts lagged the work.** Phases 10 & 11 shipped passing tests but no `VERIFICATION.md`/`VALIDATION.md`. Verified-by-execution ≠ verified-by-artifact; if the audit trail matters, run `/gsd:verify-work` per phase during execution, not retroactively.
4. **Fix review findings before they compound.** All four 13-REVIEW warnings were addressed in small, atomic `fix(13)` commits right after verification — cheap because the context was fresh.

### Cost Observations

- Model: Claude Opus / Sonnet (1M context)
- Sessions: multiple across ~2 months (2026-05-21 → 2026-07-26)
- Notable: longest-running milestone by calendar time, but purely additive (63 files, +11,626/−90) — no production behavior changed, so regression risk was contained to the test layer itself.

---

## Milestone: v1.3 — E2E Polish

**Shipped:** 2026-11-12
**Phases:** 7 (14–20) | **Plans:** 47 | **Sessions:** multiple across ~2.5 months

### What Was Built

- **Phase 14:** shared ISO week keys + pinned ordering, donut 3% floor, income focus-target reload, id-marker default category.
- **Phase 15:** full-format amounts app-wide via shared `EllipsisTooltipText`.
- **Phase 16:** stats PDF export (all-months aware), Unicode PDF font, localized expense/income PDFs, Android Share/Print-Save sheet; 22 plans after four UAT gap-closure rounds.
- **Phases 17-19:** localization completeness, income/home UX, settings and system UI polish.
- **Phase 20:** GitHub Actions CI and tag-triggered signed, obfuscated APK releases.

### What Worked

- **Gap-closure waves from UAT.** Phase 16 UAT findings were turned into numbered plans and closed in rounds, with on-device re-test as the final gate.
- **Locking decisions into STATE.md notes and tests.** Traps like the non-self-clearing `lastCreatedCategoryId` and the triple-gated auto-select are documented and test-guarded.
- **Display-only fixes** (3% donut floor) kept real amounts untouched.

### What Was Inefficient

- **Phase 16 grew to 22 plans.** UAT surfaced many adjacent issues (l10n, footer padding, empty states) that were not scoped up front.
- **Verification paperwork skipped.** `workflow.verifier=false` meant no VERIFICATION.md for any phase; several VALIDATION.md remain draft.
- **Legacy format debt** (~43 files fail `dart format`) forced care to avoid out-of-scope reformatting in every plan.
- **Phase 20 added mid-milestone** without requirement IDs.

### Patterns Established

- Shared widgets for cross-cutting display policy (`EllipsisTooltipText`, `showAppBottomSheet`, `SheetFooterPadding`).
- App-managed primitive markers in the settings box instead of Hive schema changes.
- Release flow documented in `docs/RELEASING.md`.

### Key Lessons

1. Scope UAT-adjacent fixes (l10n, spacing, empty states) up front to avoid a 22-plan phase.
2. Release workflows must be run live once before the milestone is called verified.
3. Turn the verifier back on, or accept that the audit trail will rely on SUMMARYs and tests.

### Cost Observations

- Model: Claude Opus / Sonnet
- Sessions: multiple across 2026-08-23 → 2026-11-12
- Notable: tests grew 169 → 523 while behavior changed intentionally (amount formatting).

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 7 | 21 | Initial GSD setup; single-agent sequential execution |
| v1.1 | 2 | 12 | Parallel worktree execution for Wave 2; mandatory code review gate |
| v1.2 | 4 | 16 | Wave-based test authoring; independent verifier re-runs suite; real-Hive integration harness |
| v1.3 | 7 | 47 | UAT-driven gap-closure waves; verifier disabled; CI + signed release pipeline |

### Cumulative Quality

| Milestone | Tests | Zero-Dep Domain | Typed Errors |
|-----------|-------|-----------------|--------------|
| v1.0 | 34 (use case + export) | ✓ | ArgumentError (partial) |
| v1.1 | 34 (stable) | ✓ | Typed exception enums (complete) |
| v1.2 | 169 (use case + BLoC + widget + integration) | ✓ | Typed exception enums (complete) |
| v1.3 | 523 (full suite) | ✓ | Typed exception enums (complete) |

### Top Lessons (Verified Across Milestones)

1. **Domain layer must stay Flutter-free.** Any Flutter import in `lib/domain/` is a red flag — it breaks testability and localization.
2. **Code review gate catches production bugs.** Two milestones, two mandatory reviews — both found critical issues that automated tests missed.
3. **Stream timeouts are recoverable, not catastrophic.** Committed work survives; the recovery path (manual merge + leftover commit) is well-understood.
4. **REQUIREMENTS.md checkbox state is not coverage evidence.** Two milestones running (v1.1, v1.2), execution left requirement boxes unticked despite passing work. Reconcile at the milestone audit/archive step; verify against the actual codebase, never the checkboxes.
5. **Verify by execution, and record the artifact.** v1.2 proved coverage by re-running the suite, but two phases shipped without `VERIFICATION.md`. Passing tests ≠ complete audit trail — produce the verification artifact during the phase if the record matters.
