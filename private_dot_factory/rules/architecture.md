# Architecture Defaults

Repo-specific architecture wins. These are defaults only.

- Prefer feature-first layout under `lib/features/<feature>/` for new code.
- Within a feature, use Clean Architecture layers only when the feature is non-trivial:
  - `presentation/` — widgets, BLoC/Cubit wiring, screens
  - `domain/` — pure Dart entities and repository interfaces
  - `data/` — repository implementations and data sources
- Keep `lib/core/` for shared infrastructure (DI, theme, network, database, utils, localization wiring).
- Domain entities stay pure Dart and do not import Flutter or external SDKs.
- Repositories are abstract in `domain/` and implemented in `data/` when the layered split is used.
- For modular monorepos, treat each `pubspec.yaml` subdirectory as an independent package with its own conventions.
- Do not introduce a Clean Architecture split for trivial flows; favor a single presentation file when no domain logic exists.
- Do not migrate an existing architecture to feature-first or layered Clean just to match this default.
