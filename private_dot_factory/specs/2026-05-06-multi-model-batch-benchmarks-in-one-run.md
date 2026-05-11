
## Goal

Let one launch benchmark **N (provider, model) pairs × M tasks** in a single run, with bounded parallelism and per-launch failure policy. Built around the existing `runs` / `task_runs` schema (no migration; `task_runs` already stores `providerId` + `modelId` per row), so leaderboard, README export and run-matrix stay correct without rework.

## Decisions (locked)

- **Single run, many models** — one `runId`, many (provider, model) pairs. Verified that `LeaderboardRepository`, `runSummaryToMarkdown` (README export) and `RunMatrix` already split by `(providerId, modelId)`.
- **Bounded parallel, single global cap** — one global semaphore (default 4, configurable 1–8 in Settings).
- **Multi-select chips per provider** — no presets in this plan.
- **Failure policy is per-launch** — a `RunFailurePolicy` enum on `StartRun` chosen on the New Run page.
- **Skipped failures count as zeros** — `skipAndContinue` intentionally persists a failed `task_run` with score `0.0`; leaderboard and README export should include that zero for the model. `failFast` does not create a synthetic failed row for the failed combo.

## Data shape changes

`StartRunConfig` / `StartRun` / `RunBloc` move from one-model-per-provider to many:

```dart
// before
final Map<String, String> modelByProvider;

// after
final Map<String, List<String>> modelsByProvider;
final int maxConcurrency;        // default 4, clamped to 1–8
final RunFailurePolicy onFailure; // failFast | skipAndContinue
```

`RunFailurePolicy` is a new enum in `lib/runner/run_failure_policy.dart`:

```dart
enum RunFailurePolicy { failFast, skipAndContinue }
```

`TaskRunResult` already carries `providerId` + `modelId`, no change. For skipped combo failures, persist a synthetic `TaskRunResult` with this exact shape:

- `runId`, `providerId`, `modelId`, `taskId`, `planId`: from the combo.
- `response`: `ModelResponse(rawText: '<error>', extractedCode: null, promptTokens: null, completionTokens: null, latency: Duration.zero)`.
- `evaluations`: exactly one `EvaluationResult(evaluatorId: 'combo_failure', passed: false, score: 0.0, rationale: 'combo failed during <phase>: <reason>', details: {'phase': '<phase>', 'error': '<reason>'})`.
- `aggregateScore: 0.0`.
- `completedAt: now()`.

This keeps the row visible in the run matrix and on the leaderboard as a clearly-failed cell.

## Step 1 — Core orchestration (`lib/runner/`)

1. Add `run_failure_policy.dart` with the enum.
2. Update `StartRunConfig`, `StartRun`, `RunBloc`:
   - replace `modelByProvider` with `modelsByProvider`.
   - add `maxConcurrency` and `onFailure`; constructor defaults should be `maxConcurrency = 4` and `onFailure = RunFailurePolicy.failFast` to preserve direct `StartRun` call behavior unless the UI chooses otherwise.
   - import `RunFailurePolicy` from `lib/runner/run_failure_policy.dart`.
   - update `lib/app.dart` so the route copies `modelsByProvider`, `maxConcurrency`, and `onFailure` from `StartRunConfig` into `StartRun`.
3. Refactor `RunBloc._onStart`:
   - Build and validate the normalized combos before calling `runDao.startRun`; invalid empty selections should emit `RunFailed` without creating an unfinished run row.
   - Normalize `event.modelsByProvider` before building combos:
     - for each selected provider, trim model ids, drop empty strings, and dedupe while preserving order.
     - if any selected provider has no models after normalization, throw `StateError('No models selected for <providerId>')` and emit `RunFailed` through the existing outer catch.
     - if the final combo list is empty, emit `RunFailed('No benchmark combos selected')`.
   - Load each task once before fan-out: `await task.ensureLoaded()`, then upsert/read the reference plan once per task when `useReferencePlan` is enabled. Reuse that task-level `planId` + `planMarkdown` across all provider/model combos for that task.
   - Build a flat list of `_Combo(index, task, provider, modelId, planId, planMarkdown, label)`.
   - Total = `combos.length` (was `tasks × providers`).
   - `pubspec.yaml` does **not** include `pool`; do not add a dependency. Implement a private homegrown worker pool in `run_bloc.dart` using `dart:math` only:
     - clamp `cap = event.maxConcurrency.clamp(1, 8)`.
     - start `min(cap, combos.length)` async workers over a shared `Iterator<_Combo>`.
     - workers call `iterator.moveNext()` synchronously before any `await`; Dart runs this on one isolate, so there is no preemptive mutation race.
     - keep `Object? firstError`, `StackTrace? firstStackTrace`, and `bool stopScheduling`. On `failFast`, record the first combo error, set `stopScheduling = true`, stop launching new combos, wait for already-started combos to settle, then rethrow the first error to the outer `_onStart` catch so it emits one terminal `RunFailed`.
   - Split the per-combo work into `_runCombo(_Combo combo, EvaluatorConfig config)`, which returns an unpersisted `TaskRunResult` for the existing `generate → extract → workdir.createTaskWorkdir → workdir.prepare → evaluators → aggregate` pipeline.
   - Persist only in the worker completion path. Do not swallow `runDao.persistTaskRun` errors; storage failures should fail the run even under `skipAndContinue`.
   - On combo failure before persistence:
     - `failFast`: rethrow to the worker pool.
     - `skipAndContinue`: create and persist the synthetic failed `TaskRunResult` described above, then count the combo as completed.
   - Preserve deterministic state despite parallel completions:
     - allocate `final resultSlots = List<TaskRunResult?>.filled(combos.length, null)`.
     - after a real or synthetic result is persisted, assign `resultSlots[combo.index] = result`.
     - compute `completed` from non-null slots (or increment only inside this same awaited completion block) and emit `results: List.unmodifiable(resultSlots.whereType<TaskRunResult>())`, which keeps launch order rather than completion order.
     - track in-flight labels in a mutable `Set<String> activeLabels`, but every emitted state must use `Set.unmodifiable(activeLabels)` so `RunInProgress` snapshots are immutable.
     - guard every progress emit with `if (!emit.isDone)`; do not emit after the outer catch has emitted `RunFailed`.
   - Labels should include provider, model, and task, e.g. `'${provider.displayName} / $modelId on ${task.id}'`.
   - `CancelRun` remains unwired in this plan. In-flight provider calls are not cancellable; the only required safety is avoiding late emits after bloc close via `emit.isDone`.

## Step 2 — Settings (`lib/storage/settings.dart`)

Add `getRunConcurrency()` / `setRunConcurrency(int)` to `SettingsRepository`:

- key: `_runConcurrency = 'run_concurrency'`.
- default: `4`.
- read with `int.tryParse`, falling back to `4` for null/invalid values.
- clamp both reads and writes to `1–8`.

Wire a slider in `settings_page.dart` ("Max concurrent generations") that loads this value, shows the current integer value, and saves immediately when changed. Add storage tests in `test/storage/settings_test.dart` for default, roundtrip, low clamp, high clamp, and invalid stored value fallback.

## Step 3 — New Run UI (`lib/ui/pages/new_run_page.dart`)

- `_models` becomes `Map<String, Set<String>>`.
- `_ProviderRow` replaces the single dropdown / text field with a chip-style multi-select:
  - When models can be listed: show all returned models as `FilterChip`s (selectable). Above the chips: "Select all" / "Clear". Deduplicate listed model ids before rendering.
  - When listing fails or returns empty: keep a free-text field, but accept comma-separated model ids → split, trim, drop empties, and store as a set.
  - If a provider is unchecked, keep its selection in memory but exclude it from `_canRun`, combo counts, and `StartRunConfig`.
- `_canRun`: provider checked AND its set is non-empty.
- New `SegmentedButton<RunFailurePolicy>` ("Stop on first failure" / "Skip failed and continue") above the Run button. Defaults to skip-and-continue when total combos > 5, else fail-fast.
- Show a small summary line: "Will run X (provider, model) pairs × Y tasks = Z combos, ≈ ${concurrency}× parallel".
- Read `maxConcurrency` from `SettingsRepository.getRunConcurrency()` before navigation.
- Pass `modelsByProvider`, `maxConcurrency`, `onFailure` into `StartRunConfig`.

## Step 4 — Run progress page

`RunProgressPage` already shows `completed / total` + `currentLabel`. Update to:
- Replace single `currentLabel` with `currentLabels: Set<String>` in `RunInProgress` (small breaking change, internal). Give it a default of `const {}` and include it in `props`.
- Drop `currentRawResponse` from `RunInProgress` and `RunProgressPage`; it is misleading with parallel calls.
- Update all `RunInProgress` constructors and pattern matches. Existing grep shows only `run_bloc.dart`, `run_state.dart`, and `run_progress_page.dart` use `currentLabel` / `currentRawResponse`.
- Render an in-flight list ("running 3 of 4 slots") from `currentLabels.toList()..sort()` so widget tests are stable.

## Step 5 — Tests

- `test/runner/run_bloc_test.dart`:
  - many-models-one-provider produces N task_runs per task.
  - many-providers + many-models matrix counts correct.
  - duplicate/blank model ids are normalized, and an empty model list produces `RunFailed`.
  - `failFast` emits `RunFailed` for the first error and does not call `finishRun`.
  - `skipAndContinue` records the synthetic failed `TaskRunResult` with evaluator id `combo_failure`, score `0.0`, `response.rawText == '<error>'`, and emits `RunCompleted`.
  - concurrency cap: feed a fake provider that records the high-water mark of in-flight calls and assert it ≤ cap.
- `test/runner/run_bloc_plan_aware_test.dart`: with multiple models for one task, verify `ensureLoaded` / reference plan upsert behavior still happens once per task and all results carry the same task-level `planId`.
- `test/ui/new_run_page_test.dart`: chip multi-select toggles populate the selection set, "Select all" / "Clear" work, comma-separated fallback trims and dedupes, summary combo count updates, and `StartRunConfig` carries `modelsByProvider`, `maxConcurrency`, and `onFailure`.
- `test/storage/settings_test.dart`: add concurrency default, roundtrip, clamp, and invalid-value fallback coverage.
- Update existing tests that constructed `StartRun(modelByProvider: ...)` or asserted `StartRunConfig.modelByProvider` to use the new map and failure/concurrency defaults.

## Step 6 — Verification

Required:

```sh
fvm flutter analyze
fvm flutter test
```

Optional manual sanity check if provider credentials are already configured: launch a 2-provider × 3-model × 2-task run against Ollama Cloud + Anthropic, confirm leaderboard shows 6 rows and README publish lists each (provider, model) once. Do not treat missing external credentials as a verification failure.

## Out of scope (explicit)

- Saved presets / "model sets" — deferred to a follow-up plan.
- Per-provider concurrency caps — single global cap only for v1.
- Cancel mid-run — `CancelRun` event already exists but isn't wired; leaving as-is to keep this plan small. Parallel work should still avoid late emits after bloc close.
- Cost estimation / budget guardrails — separate concern.

## Touched files (estimate)

- New: `lib/runner/run_failure_policy.dart`, optionally `test/runner/run_bloc_concurrency_test.dart`.
- Modified: `lib/app.dart`, `run_event.dart`, `run_state.dart`, `run_bloc.dart`, `start_run_config.dart`, `new_run_page.dart`, `run_progress_page.dart`, `settings_page.dart`, `settings.dart`, existing runner/UI/settings tests, any test fixture using the old map.
- Unchanged: `pubspec.yaml` (verified no `pool` dependency; use the homegrown worker pool instead of adding one).

## Pipeline

Will be executed via the standard plan-reviewer → coder → final-reviewer pipeline once approved.
