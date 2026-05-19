# BLoC and Cubit Rules

Repo-specific state management wins. Do not force BLoC into Riverpod, Provider, GetX, MobX, or other consistent architectures.

- Prefer local state for simple ephemeral UI state.
- Prefer Cubit for simple feature state and direct actions.
- Prefer BLoC for complex event-driven flows, auditability, and strict state transitions.
- Keep states immutable, explicit, and easy to test.
- Avoid boolean soup; use clear status/value objects or sealed state variants when the repo supports them.
- Use `BlocSelector`, `buildWhen`, and focused builders to avoid broad rebuilds.
- Use `BlocListener` for one-off effects; do not trigger navigation/snackbars from builders.
- Use `bloc_test` and `mocktail` when the repo already uses them.
- Prefer providing route/feature-scoped BLoCs via `BlocProvider` / `MultiBlocProvider` at the route builder level (e.g., inside `go_router` `builder`), not inside screen widget constructors. This pairs with `injectable` factory registration so each navigation gets a fresh instance.
- Reserve global/app-wide BLoCs and Cubits for cross-cutting concerns (auth, settings, theme); register them as lazy singletons and provide once at the app root.
- Events: name as `<Feature><Action>` (e.g., `AuthSignInRequested`, `SettingsInitialized`).
- States: prefer sealed/freezed state variants (`Initial`, `Loading`, `Success`, `Failure`) over boolean flags; carry typed payloads, not raw strings, where the repo supports it.
