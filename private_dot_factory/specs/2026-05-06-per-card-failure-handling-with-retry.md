## Goal
Replace the full-page failure screen with per-card failure handling. Each failed combo gets its own red card with the error message, expandable stacktrace, and a "Retry" button that re-queues into the existing worker pool. The run keeps streaming alongside, never gets blocked by a single failure.

Also: stop swallowing the persist-failure path that silently kills workers (the suspected cause of "8 → 2" with no retry prompt), and surface error details on each card.

## Decisions (already confirmed)
- Drop `failFast` policy entirely — only per-card retries.
- Failed combos persist as synthetic `TaskRunResult` (score 0); retry overwrites the row.
- Retry re-queues into the existing worker pool (respects `maxConcurrency`).
- Per-card UX: short error message visible, stacktrace under an `ExpansionTile`.

## Files to change

### Domain / state
- **`lib/runner/run_failure_policy.dart`** — delete the file (and all references).
- **`lib/runner/run_event.dart`**
  - Drop `onFailure` from `StartRun`.
  - Add new event:
    ```dart
    class RetryCombo extends RunEvent {
      const RetryCombo({required this.runId, required this.failedIndex});
      final String runId;
      final int failedIndex;
      @override List<Object?> get props => [runId, failedIndex];
    }
    ```
    `failedIndex` is the original combo index (`_Combo.index`), not the failed-list position. It must remain stable across retries and must be used as the key into `_combos`, `_resultSlots`, and `_failed`.
  - Add new event:
    ```dart
    class FinishRun extends RunEvent {
      const FinishRun(this.runId);
      final String runId;
      @override List<Object?> get props => [runId];
    }
    ```
- **`lib/runner/start_run_config.dart`** — drop `onFailure` field.
- **`lib/runner/failed_combo_snapshot.dart`** — new file:
  ```dart
  class FailedComboSnapshot extends Equatable {
    const FailedComboSnapshot({
      required this.index, required this.label,
      required this.providerId, required this.modelId, required this.taskId,
      required this.errorMessage, required this.stackTrace,
      required this.failedAt,
    });
    final int index; final String label;
    final String providerId; final String modelId; final String taskId;
    final String errorMessage; final String? stackTrace;
    final DateTime failedAt;
    @override List<Object?> get props => [index, label, providerId, modelId, taskId, errorMessage, stackTrace, failedAt];
  }
  ```
- **`lib/runner/run_state.dart`**
  - Import `failed_combo_snapshot.dart`.
  - `RunInProgress` gains:
    - `final int pending` (queued, not active; defaults to `0`, included in `props`).
    - `final List<FailedComboSnapshot> failed` (defaults to `[]`, included in `props`).
  - `RunFailed` is reserved for fatal cases (no providers/combos, DB unreachable on `startRun`/`finishRun`); drop the `retry` parameter — UI will simply show the error and a "Back" affordance.

### Bloc
- **`lib/runner/run_bloc.dart`**
  - Add `dart:collection` for `Queue` and `package:flutter/foundation.dart` for `debugPrint`; remove the `run_failure_policy.dart` import.
  - Register handlers for `StartRun`, `RetryCombo`, and `FinishRun`.
  - Remove all `onFailure`/`failFast` branches and the `firstError`/`retry`/`stopScheduling` machinery.
  - Keep scheduler state on the bloc instance and reset it at the start of every `StartRun`:
    - `_currentRunId`
    - `_existingCount`
    - `_combos: List<_Combo>`
    - `_resultSlots: List<TaskRunResult?>`
    - `_failed: Map<int, FailedComboSnapshot>`
    - `_retrying: Set<int>`
    - `_pendingQueue: Queue<int>`
    - `_active: Map<int, RunProgressSnapshot>`
    - `_runningWorkers`
    - `_maxConcurrency`
  - Replace `sharedIterator` with a queue-based scheduler:
    - Seed `_pendingQueue` with every combo index after tasks/plans are loaded.
    - `_ensureWorkers(Emitter<RunState> emit)` starts only `min(_maxConcurrency - _runningWorkers, _pendingQueue.length)` additional workers.
    - Each worker increments `_runningWorkers` before its loop and decrements it in `finally`.
    - Each worker synchronously pops one index from `_pendingQueue`, writes `_active[index]`, and emits before the first `await`. Because Dart runs this code on one isolate, these synchronous pop/update sections are safe as long as there is no `await` between checking/removing the queue item and marking it active.
    - Do not hold a `Queue` iterator across awaits.
    - Do not spawn unawaited workers that will use a completed Bloc `Emitter`; every handler that starts workers must await the worker futures it starts (or await a helper such as `_drainQueue(emit)`) before returning.
  - On combo failure (any cause): build a `FailedComboSnapshot` with `errorMessage = e.toString()` and `stackTrace = st.toString()`, persist a synthetic `TaskRunResult` (current behavior), record in `_failed[index]`, remove from `active`, emit progress, and continue. **Do not stop scheduling.**
  - Store the successfully persisted synthetic failure in `_resultSlots[index]`, but do not include indices present in `_failed` in the visible `RunInProgress.results` list; they render only in the Failed section. `completed` can still count populated slots so progress reaches total when every combo is either succeeded or failed. On retry, clearing the slot makes the progress count move back.
  - If the synthetic-persist itself throws: `debugPrint` + add to `_failed` with note "persist failed: …" and continue (do not exit the worker, do not silently die). Leave `_resultSlots[index]` null in this exceptional path because there is no persisted row to show in final results.
  - Add `on<RetryCombo>(_onRetry)` handler:
    1. Reject if `state` is not `RunInProgress`, `runId != _currentRunId`, `failedIndex` is outside `_combos`, `_failed` does not contain the index, `_retrying` already contains it, `_pendingQueue` already contains it, or `_active` already contains it.
    2. Add `failedIndex` to `_retrying` synchronously before the first `await`. This makes double-click retry idempotent without exposing the index to workers before the old row is deleted.
    3. Delete the prior failed `TaskRun` row by composite key (see DAO change below). If delete fails, remove the index from `_retrying`, leave the failed card in place, and emit fatal `RunFailed` because retrying would otherwise risk duplicate rows.
    4. After the delete succeeds, remove `_failed[failedIndex]`, clear `_resultSlots[failedIndex]`, remove the index from `_retrying`, push `failedIndex` into `_pendingQueue`, and emit progress.
    5. Await `_ensureWorkers(emit)` / `_drainQueue(emit)` so the retry uses the same queue/cap machinery and respects `maxConcurrency`.
  - Add `on<FinishRun>(_onFinishRun)` handler:
    1. Reject unless `state is RunInProgress`, `runId == _currentRunId`, `_pendingQueue.isEmpty`, `_active.isEmpty`, `_runningWorkers == 0`, and `_failed.isNotEmpty`.
    2. Call `runDao.finishRun(runId, now())`.
    3. Emit `RunCompleted` with `_resultSlots.whereType<TaskRunResult>()` (this includes successfully persisted synthetic failures).
    4. If `finishRun` throws, emit fatal `RunFailed('$e')`.
  - Completion semantics:
    - Clean run: when `_pendingQueue.isEmpty && _active.isEmpty && _runningWorkers == 0 && _failed.isEmpty && _resultSlots.whereType<TaskRunResult>().length == _combos.length`, call `runDao.finishRun` and emit `RunCompleted` automatically.
    - Run with unresolved failures: when `_pendingQueue.isEmpty && _active.isEmpty && _runningWorkers == 0 && _failed.isNotEmpty`, stay in `RunInProgress` indefinitely so retry buttons remain usable. `runDao.finishRun` is called only if the user clicks `Finish run`.
    - Navigating away without clicking `Finish run` disposes the page/bloc and leaves the DB run unfinished. That matches the explicit-finish model and means it will still appear in the existing in-progress UI instead of being silently marked complete.
    - Do not add an auto-finish for the unresolved-failure case.

### DAO
- **`lib/storage/dao/run_dao.dart`**
  - Add:
    ```dart
    Future<void> deleteTaskRunByKey({
      required String runId, required String providerId,
      required String modelId, required String taskId,
    }) async {
      await _db.transaction(() async {
        final matches = await (_db.select(_db.taskRuns)
              ..where((t) => t.runId.equals(runId) & t.providerId.equals(providerId)
                  & t.modelId.equals(modelId) & t.taskId.equals(taskId)))
            .get();
        for (final tr in matches) {
          await (_db.delete(_db.evaluations)..where((e) => e.taskRunId.equals(tr.id))).go();
        }
        await (_db.delete(_db.taskRuns)
              ..where((t) => t.runId.equals(runId) & t.providerId.equals(providerId)
                  & t.modelId.equals(modelId) & t.taskId.equals(taskId)))
            .go();
      });
    }
    ```
  - Add a DAO test proving this deletes both the matching task run row(s) and their evaluations, and does not delete other task/model/provider rows in the same run.

### UI
- **`lib/ui/pages/run_progress_page.dart`**
  - Delete the retry-oriented `_FailedView` (centered giant button). Replace it with a fatal-only small centered error message and Back affordance for `RunFailed`.
  - Make the `AppBar` actions state-aware (for example by moving the `Scaffold` inside the `BlocBuilder`, or by using a nested `BlocBuilder` for `actions`) so it can show `Finish run`.
  - In `_ProgressView`, render a new "Failed" section between active and completed:
    ```
    if (failed.isNotEmpty) [
      Text('Failed (${failed.length})'),
      ...failed.map((f) => _FailedCard(snapshot: f, onRetry: () => bloc.add(RetryCombo(runId: runId, failedIndex: f.index)))),
    ]
    ```
    Pass `runId`, `pending`, and `failed` into `_ProgressView` from `RunInProgress`.
  - New widget `_FailedCard`:
    - Card with `colorScheme.errorContainer` background.
    - Title: `f.label`. Subtitle: `f.errorMessage` (single line, truncated).
    - Trailing: `FilledButton.tonalIcon(icon: Icons.refresh, label: 'Retry')`.
    - `ExpansionTile` with stacktrace in monospace 11pt (only shown if `stackTrace != null`).
  - For the fatal `RunFailed` state: keep a small centered error message (no retry button — only a "Back" link), since this case now genuinely means we couldn't even start or couldn't finish.
  - Add a "Finish run" `TextButton` in the AppBar actions when `failed.isNotEmpty && pending == 0 && active.isEmpty`, which sends `FinishRun(runId)` to mark `runDao.finishRun` and emit `RunCompleted` keeping the failed cards as the persisted synthetic rows.

### New-Run page
- **`lib/ui/pages/new_run_page.dart`**
  - Remove the `SegmentedButton<RunFailurePolicy>` and `_failurePolicy` field/`_computeFailureDefault()`.
  - Remove `onFailure` from the `StartRunConfig` construction.

### App wiring
- **`lib/app.dart`** (or wherever the route reads `StartRunConfig`) — drop `onFailure` propagation.

## Tests
- **`test/runner/run_bloc_test.dart`** (update existing):
  - Replace the `failFast` and `skipAndContinue` tests with per-card failure tests.
  - Given multiple combos where one provider/model throws, assert the bloc emits `RunInProgress` with `failed.length == 1`, keeps scheduling the other combos, and does not emit `RunFailed`.
  - Assert a clean run still calls `finishRun` automatically and emits `RunCompleted`.
  - Assert a run with unresolved failures stays in `RunInProgress`, leaves `run.completedAt == null`, and emits `RunCompleted` only after `FinishRun`.
  - Given a fake provider whose first combo throws and then succeeds, assert `RetryCombo(runId, failedIndex: originalComboIndex)` removes the failed entry, re-runs the same combo index, produces a completed result, and deletes the prior synthetic row/evaluations before the successful row is inserted.
  - Add a duplicate-retry test (two retry events or repeated button click for the same `failedIndex`) proving the same combo is not queued twice and the provider call count is correct.
  - Keep/update the existing concurrency-cap test so retry work also never exceeds `maxConcurrency`.
  - Add a synthetic-persist-failure regression test if practical: a DAO fake that throws from `persistTaskRun` for the synthetic result should not silently kill the remaining workers.
- Widget test for `RunProgressPage` that the failed card renders with retry button and stacktrace expansion.
- Widget test for the `Finish run` AppBar action dispatching `FinishRun(runId)` only when `failed.isNotEmpty && pending == 0 && active.isEmpty`.
- Update `test/ui/pages/new_run_page_test.dart`, `test/ui/pages/new_run_page_plan_toggle_test.dart`, and any other existing `failFast`/`skipAndContinue` tests to remove the policy and assert `StartRunConfig` no longer carries `onFailure`.
- Add/update `test/storage/run_dao_test.dart` coverage for `deleteTaskRunByKey`.

## Verification
Run, in order:
1. `dart analyze`
2. `dart format --set-exit-if-changed .`
3. `flutter test`

Done when all pass and the new bloc tests are green.

## Out of scope (intentionally not doing)
- Auto-retry with exponential backoff (manual retry only, per your decision).
- Cancelling/cleaning up partial workdirs for failed combos (those are already harmless on disk).
- Investigating *why* the underlying provider calls fail — the new error/stacktrace shown on each card should make that diagnosable in your next run.

## Execution
Per your AGENTS.md, after you approve I'll dispatch the multi-agent pipeline:
1. `plan-reviewer` reviews this spec.
2. `coder` implements + verifies (analyze + tests).
3. `final-reviewer` audits the diff against the plan.

You said no worktree, so all work happens directly on `main` (uncommitted).

## Open Questions
- None.