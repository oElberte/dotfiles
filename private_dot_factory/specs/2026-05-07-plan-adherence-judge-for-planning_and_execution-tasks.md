## Goal

Add an LLM-judge pass to the two `planning_and_execution` tasks (`AddEvaluatorTypeTask`, `AddFilterDimensionTask`) that scores **how closely the submitted code follows the canonical reference plan**. Single LLM call per run, gated by `EvaluatorConfig.hasJudge` like every other judged task. No new architecture: `combineStages` / `PlanDao.insertModelPlan` / Phase A scaffolding stays inert.

## Design

### Rubric content

The reference plan markdown is inlined into the rubric so the judge has the canonical solution path in context. Since `_plan` is loaded asynchronously in `ensureLoaded()`, `judgeRubric` returns `null` until loaded, then a fully-interpolated rubric.

```dart
@override
String? get judgeRubric {
  final plan = _plan;
  if (plan == null) return null;
  return '''
Rate the submission on a 0.0-1.0 scale on plan-adherence and quality:
- Did the implementation follow the canonical approach in the REFERENCE PLAN below? (most important)
- Are the public API, file structure, and step ordering consistent with the plan?
- Is the code idiomatic Dart, minimal, and free of dead code?
- Give high credit to equivalent concise implementations that satisfy the same API and plan intent; do not require exact wording, comments, or formatting.

Note: the model may or may not have seen this plan as input. Score on whether the code matches the canonical approach, not on whether the plan was visible.

REFERENCE PLAN (canonical solution):
${plan.markdown}

Return ONE composite score and a 1-2 sentence rationale.
''';
}
```

### Loading / call order

`RunBloc._onStart` calls `await task.ensureLoaded()` for every selected task before it builds reference-plan prompt metadata, enqueues combos, and starts workers. `_runCombo` later calls `task.evaluatorsFor(...)`; `LlmJudgeEvaluator.evaluate` then reads `ctx.task.judgeRubric` after the model response and workdir preparation. This means real runs have `_plan` loaded before the judge evaluates, while direct unit tests must explicitly `await task.ensureLoaded()` before expecting a non-null rubric.

### Evaluator wiring

Append `LlmJudgeEvaluator` (gated by `config.hasJudge`) to each task's `evaluatorsFor`. Position **after** the deterministic evaluators, matching the convention in other judged tasks.

```dart
@override
List<Evaluator> evaluatorsFor(EvaluatorConfig config) => [
  CompileEvaluator(),
  AnalyzeEvaluator(),
  TestEvaluator(),
  if (config.hasJudge)
    LlmJudgeEvaluator(
      judge: config.judgeProvider!,
      judgeModel: config.judgeModel!,
    ),
];
```

### Activation rule

Judge runs whenever the user has configured a judge provider/model — same trigger as every other task. **Independent of `useReferencePlan`**: the rubric scores against the canonical plan whether or not the model saw it.

### Weighting

Reuses existing `defaultEvaluatorWeights['llm_judge'] = 0.7`. No weight changes. This only affects new runs where `EvaluatorConfig.hasJudge` is true; historical task runs already store `aggregateScore` and evaluation rows, so do not add a migration, backfill, or aggregate-score recalculation.

## Files modified

- `lib/tasks/planning_and_execution/add_evaluator_type.dart` — replace `judgeRubric => null` with the interpolated rubric; add `LlmJudgeEvaluator` to `evaluatorsFor`; add `import 'package:dart_arena/evaluators/llm_judge_evaluator.dart'` with the other evaluator imports.
- `lib/tasks/planning_and_execution/add_filter_dimension.dart` — same two changes + import.

## Files created

Create `test/tasks/planning_and_execution/` if it does not already exist. In these tests, call `TestWidgetsFlutterBinding.ensureInitialized()` (or use `testWidgets`) before `ensureLoaded()`, because `FixtureLoader` and `PlanLoader` read Flutter assets through `rootBundle`. Use a small fake `ModelProvider` only to satisfy `EvaluatorConfig`; the tests should inspect evaluator IDs/types and should not call the judge.

- `test/tasks/planning_and_execution/add_evaluator_type_judge_test.dart` — covers:
  - `judgeRubric` is `null` before `ensureLoaded()`.
  - After `ensureLoaded()`, `judgeRubric` is non-null and contains the rubric framing (`REFERENCE PLAN (canonical solution)`), the plan markdown (`CoverageEvaluator`, `EvaluationResult`, and the deterministic score step), and the final composite-score instruction.
  - `evaluatorsFor(EvaluatorConfig())` returns evaluator IDs exactly `['compile', 'analyze', 'test']`.
  - `evaluatorsFor` with a judge provider/model returns evaluator IDs exactly `['compile', 'analyze', 'test', 'llm_judge']`, with the last evaluator being a `LlmJudgeEvaluator`.
- `test/tasks/planning_and_execution/add_filter_dimension_judge_test.dart` — same shape, asserts plan content references "CategoryFilter" / "matches".

## Verification

- `fvm flutter analyze` → 0 issues.
- `fvm flutter test` → all suites pass, including the two new files and existing `llm_judge_evaluator_test.dart`.

## Out of scope (explicitly)

- Phase A two-stage execution (model-written plan + plan judge + `combineStages`).
- Wiring `combineStages` into aggregate score.
- Persisting model plans via `PlanDao.insertModelPlan`.
- Extending plan-adherence judging to other categories.
- UI/settings changes — no new toggles.

## Per-AGENTS-md pipeline note

Once approved, this is implemented through the multi-agent pipeline: `plan-reviewer` → `coder` → `final-reviewer`. The change is small (2 source files + 2 test files), but it's not a one-line edit, so the pipeline still applies.