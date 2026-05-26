---
name: flutter-bloc
description: Use when implementing, refactoring, testing, or reviewing Flutter BLoC/Cubit state management, events, states, effects, and bloc_test coverage
---

# Flutter BLoC

Use BLoC/Cubit only when it matches the repository or the feature complexity.

## Decisions

- Local state: ephemeral UI-only state.
- Cubit: simple feature state and direct actions.
- BLoC: complex event-driven flows, auditability, concurrency, strict transitions.
- Existing repo pattern wins over personal preference.

## Rules

- Keep events user/system-intent focused.
- Keep states immutable and explicit.
- Avoid boolean soup; prefer clear status/value objects or sealed variants when available.
- Keep side effects in BLoC/Cubit or services, not widgets.
- Use `BlocListener` for one-off effects.
- Use `BlocSelector` or `buildWhen` for narrow rebuilds.
- Test success, failure, loading, empty, cancellation/concurrency cases when relevant.
- Use `bloc_test` and `mocktail` only when already present or accepted by the repo.

## Output

1. Existing state pattern
2. Cubit/BLoC choice and why
3. State model
4. Event/action flow
5. Tests and validation
