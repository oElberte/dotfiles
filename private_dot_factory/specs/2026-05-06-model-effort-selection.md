## Plan: Model Effort Selection

### Summary
Add `reasoning_effort` support for selected OpenAI-compatible providers. Models gain effort variants shown as separate chips (e.g., `deepseek-v4-pro::high`, `deepseek-v4-pro::max`). Use `::` as the UI/config separator because it is unlikely to appear in provider model IDs, but strip it before provider requests and never use the encoded value raw as a filesystem path segment.

### Providers & Efforts
| Provider | Efforts | 
|---|---|
| DeepSeek | `high`, `max` |
| OpenAI | `low`, `medium`, `high`, `xhigh` |
| OpenCode Go | `low`, `medium`, `high`, `max` |
| OpenRouter | `low`, `medium`, `high`, `max` |
| Anthropic | skipped (different mechanism) |
| Ollama | none |
| DroidExec | none |

### Design notes / edge cases
- Keep the encoded model ID approach instead of introducing a new structured `(model, effort)` selection object. A structured object would be cleaner long-term, but it would widen this change across `StartRunConfig`, storage, analytics, exports, and UI widgets. The encoded string is the smallest compatible change because the runner already carries model IDs as strings.
- Parse effort with `lastIndexOf('::')`, not a plain `split`, and only treat the suffix as an effort if it is present in that provider's configured effort list. This prevents accidental stripping of freeform model IDs that contain `::` or unsupported effort names.
- When an effort suffix is recognized, send the base model ID as `model` and add `reasoning_effort` to the OpenAI-compatible request body. When no recognized suffix exists, send the model ID unchanged and omit `reasoning_effort`.
- Apply parsing in both `generate()` and `generateStream()` so streaming and non-streaming runs behave the same.
- Keep raw persisted/display model IDs encoded (`model::effort`) so leaderboard/export rows distinguish effort variants, but sanitize model IDs before creating workdir paths because `::` contains `:` and is invalid in Windows path segments.
- No database migration is needed because `model_id` is already stored as text and the encoded variant remains a string.

### Changes

**1. `lib/providers/model_provider.dart`** — Add `ModelInfo` class, change `listModels()` return type:
```dart
import 'package:equatable/equatable.dart';

class ModelInfo extends Equatable {
  final String id;
  final List<String> efforts;
  const ModelInfo({required this.id, this.efforts = const []});

  @override
  List<Object?> get props => [id, efforts];
}
```
Change the abstract method to `Future<List<ModelInfo>> listModels();`.

**2. `lib/providers/openai_compatible_provider.dart`** — Accept `defaultEfforts` in constructor and store it as `final List<String> defaultEfforts;`.
- Update `listModels()` to return `ModelInfo(id: modelId, efforts: defaultEfforts)` for each `/models` result.
- Add a small private helper that returns `(baseModel, effort)` by using `lastIndexOf('::')` and validating the suffix against `defaultEfforts`.
- Update `generate()` and `generateStream()` to call the helper, set request `model` to the base model, and include `'reasoning_effort': effort` only when `effort != null`.
- Keep local/custom OpenAI-compatible providers valid by allowing `defaultEfforts` to default to `const []`.

**3. Each OpenAI-compatible provider** — Pass effort list via constructor.
- `DeepSeekProvider`: `['high', 'max']`
- `OpenAIProvider`: `['low', 'medium', 'high', 'xhigh']`
- `OpenCodeGoProvider`: `['low', 'medium', 'high', 'max']`
- `OpenRouterProvider`: `['low', 'medium', 'high', 'max']`
- `provider_factory.dart`: leave the generic `local_openai` provider with the default empty effort list.
- `OpenCodeGoProvider.listModels()` needs extra care: after `super.listModels()` returns `List<ModelInfo>`, filter on `info.id`; when falling back to `_chatModels`, wrap each ID as `ModelInfo(id: id, efforts: defaultEfforts)`.

**4. Non-OpenAI providers** — Update `listModels()` return type (no efforts).
- `AnthropicProvider`, `OllamaProvider`, and `DroidExecProvider` should return `ModelInfo(id: existingId)` with the default empty effort list.
- Update every in-test fake/stub `ModelProvider` implementation to return `Future<List<ModelInfo>>`.

**5. `lib/ui/pages/new_run_page.dart`** — Update listed model types and flatten effort variants.
- Change `_modelsFuture`, `FutureBuilder`, and `_ListedChipSelector.listedModels` from `List<String>` to `List<ModelInfo>`.
- In `_ListedChipSelector`, flatten each listed model into selectable chip IDs: if `efforts.isEmpty`, use `id`; otherwise use `id::effort` for every effort.
- Deduplicate by flattened chip ID so `Select all`, `Clear`, counts, and selected-state checks operate on the exact values that will flow into `StartRunConfig`.
- Leave `_FreeformChipInput` unchanged; advanced users may type either plain model IDs or valid `model::effort` IDs manually.

**6. `lib/runner/run_bloc.dart` and `lib/runner/start_run_config.dart`** — No request-shaping changes needed; `model::effort` flows through the existing model ID string and OpenAI-compatible providers parse it at generation time.

**7. `lib/runner/workdir_manager.dart`** — Sanitize model ID path segments.
- `createTaskWorkdir()` currently joins `modelId` directly into the path. Add a private path-segment sanitizer and use it for the directory segment derived from `modelId`; `Uri.encodeComponent(modelId)` is a good fit because it handles `:`, `/`, and `%` without collisions.
- Preserve the unsanitized model ID in persisted `TaskRunResult`, labels, exports, and analytics; only the filesystem segment should be sanitized.
- Cover both `:` from `::` and `/` from existing OpenRouter-style model IDs.

**8. Tests to update/add**
- `test/providers/openai_compatible_provider_test.dart`: update `listModels` expectations to `ModelInfo`, assert listed models receive `defaultEfforts`, assert `generate()` strips `model::effort` and includes `reasoning_effort`, assert `generateStream()` does the same, and assert unknown suffixes are not stripped.
- `test/providers/opencode_go_provider_test.dart`: update assertions to inspect `ModelInfo.id` and verify OpenCode Go efforts are attached to fallback/listed chat models.
- `test/providers/anthropic_provider_test.dart`, `test/providers/droid_exec_provider_test.dart`, and any future Ollama list-model tests: update assertions to inspect `ModelInfo.id`.
- `test/providers/openai_provider_test.dart`, `test/providers/deepseek_provider_test.dart`, and `test/providers/openrouter_provider_test.dart`: add coverage that each provider exposes the expected `defaultEfforts`.
- `test/providers/provider_factory_test.dart`: assert `local_openai` has no default efforts and enabled cloud OpenAI-compatible providers have the expected effort lists.
- `test/ui/pages/new_run_page_test.dart`: update fake providers to return `ModelInfo`; add a widget test that a model with two efforts renders two effort chips and that `Select all` selects both flattened IDs.
- All `ModelProvider` stubs in `test/runner/*`, `test/evaluators/llm_judge_evaluator_test.dart`, and `test/ui/pages/run_progress_page_test.dart` must be updated for the `listModels()` signature.
- `test/runner/workdir_manager_test.dart`: add a case proving model IDs like `deepseek-v4-pro::high` and `openai/gpt-4o` create valid directories under a sanitized single model segment.

### Verification
- Run existing tests: `flutter test`
- Run lint: `flutter analyze`