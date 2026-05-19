# Testing Rules

- Prefer tests that prove behavior, not implementation details.
- For bug fixes, reproduce the failure before fixing when feasible.
- Cover success, failure, empty, loading, and edge states relevant to the change.
- For BLoC/Cubit, prefer `bloc_test` and explicit state sequence assertions when available.
- For widgets, verify visible behavior and user interaction, not private implementation.
- Keep mocks minimal and use real objects when practical.
- Run the narrowest relevant tests first, then broader validation if the change warrants it.
- If validation cannot run, explain why and what should be run manually.
- Mirror the `lib/` structure under `test/` (e.g., `lib/features/foo/bar.dart` → `test/features/foo/bar_test.dart`). Keep shared helpers and mocks in dedicated folders (`test/helpers/`, `test/mocks/`, `test/fixtures/`).
- When generators are configured (freezed, json_serializable, injectable, drift), run codegen before running tests so generated sources are current. See `codegen.md`.
- Exclude generated and localization sources from coverage targets when the repo already does so.
