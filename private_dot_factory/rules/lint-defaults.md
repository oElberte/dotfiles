# Lint Defaults

Only apply when the repo asks for stricter analyzer rules or has no analyzer rules beyond the SDK default. Do not change a repo's existing lint configuration without being asked.

When adding rules, prefer `package:flutter_lints/flutter.yaml` as the base. Consider `package:very_good_analysis/analysis_options.yaml` only if the repo already uses it.

Common rules that repeated across multiple Flutter repos and are reasonable defaults to suggest:

- `always_declare_return_types`
- `always_use_package_imports`
- `avoid_void_async`
- `cancel_subscriptions`
- `close_sinks`
- `prefer_final_locals`
- `prefer_single_quotes`
- `sort_constructors_first`
- `sort_unnamed_constructors_first`
- `throw_in_finally`
- `unawaited_futures`
- `unnecessary_lambdas`
- `unnecessary_parenthesis`
- `unnecessary_statements`
- `use_super_parameters`

Analyzer behavior to consider:

- Exclude generated files (`**/*.g.dart`, `**/*.freezed.dart`, `**/*.gr.dart`, `lib/generated/**`, `lib/l10n/generated/**`) from analysis.
- `strict-casts: true` when the codebase can support it.
- Treat `missing_required_param` and `missing_return` as errors when the project can tolerate it.

Do not invent project-specific lints. Promote a rule only when it is already used or explicitly requested.
