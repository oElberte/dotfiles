# Flutter Rules

Repo-specific conventions win over these defaults.

- Use the repository's existing architecture, state management, routing, DI, theme, and testing patterns first.
- If `.fvmrc` or `.fvm/` exists, use `fvm flutter` and `fvm dart` for every Flutter/Dart command.
- Keep business logic out of widgets.
- Prefer small, composable, theme-aware widgets over large `build` methods.
- Model loading, empty, success, and error states explicitly.
- Avoid unnecessary Clean Architecture ceremony for simple flows.
- When generators are configured (freezed, json_serializable, injectable, drift, intl_utils), run codegen before `flutter analyze` / `flutter test`. See `codegen.md`.
- Validate in this order when applicable: codegen → `flutter analyze` → narrow `flutter test` → broader `flutter test`.

See also:

- `architecture.md` — feature-first and Clean Architecture defaults
- `bloc.md` — BLoC/Cubit defaults
- `routing.md` — `go_router` defaults
- `dependency-injection.md` — `get_it` + `injectable` defaults
- `localization.md` — ARB + `context.l10n` defaults
- `codegen.md` — `build_runner` workflow
- `lint-defaults.md` — common analyzer/lint rules
- `widget-composition.md` — widget API guidance
- `testing.md` — testing posture
