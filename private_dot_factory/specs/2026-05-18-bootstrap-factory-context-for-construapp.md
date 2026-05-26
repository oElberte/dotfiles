# Bootstrap Factory Context Plan

I'm using the writing-plans skill to create the implementation plan.

## 1. Proposed repo context structure

Create repo-specific Factory context that mirrors the current Flutter app and explicitly overrides relevant global defaults without changing production code, tests, dependencies, or existing `CLAUDE.md` files.

```text
AGENTS.md
.factory/
  memories.md
  rules/
    flutter.md
    architecture.md
    validation.md
```

Proposed responsibilities:

- `AGENTS.md`: primary entry point for Factory/Droid in this repo; concise project overview, command shortcuts, high-priority repo rules, and pointers to `.factory/rules/*`.
- `.factory/memories.md`: durable repository facts inferred from the codebase: app purpose, tech stack, current phase/features, existing generated files, known current repo state.
- `.factory/rules/flutter.md`: Flutter/FVM, localization, widgets, BLoC, routing, codegen, testing, and validation rules.
- `.factory/rules/architecture.md`: feature-first clean architecture, offline-first data flow, Drift/Supabase schema rules, DI conventions, error handling, sync/storage conventions.
- `.factory/rules/validation.md`: practical validation checklist and command order for this repo.

No `.factory/skills/*` or `.factory/droids/*` will be created unless a future task needs repo-specific agent workflows. This avoids inventing conventions.

## 2. Files to create/update

Create only these files because `.factory/` does not currently exist and no repo `AGENTS.md` exists:

1. `AGENTS.md`
2. `.factory/memories.md`
3. `.factory/rules/flutter.md`
4. `.factory/rules/architecture.md`
5. `.factory/rules/validation.md`

Existing files to read as source material only, not modify:

- `README.md` — currently default Flutter template and not authoritative.
- `CLAUDE.md` — authoritative existing project instructions.
- Feature/module `CLAUDE.md` files under `lib/features/*/` and `lib/core/*/`.
- `pubspec.yaml`, `.fvmrc`, `l10n.yaml`, `analysis_options.yaml`.
- Representative code under `lib/app`, `lib/core`, `lib/features`, and `test`.

## 3. Exact conventions inferred from code

### Project overview

- `construapp` is a mobile-first Flutter app for construction project management.
- Current implemented areas include auth/profile setup, projects, diary entries, photos, tasks, weather, sync/network infrastructure, Drift database, DI, and localization.
- Target domain is Brazilian construction workflows; Portuguese (`pt`) is the primary localization template.

### Commands

- Flutter version is pinned by `.fvmrc` to `3.41.6`; use `fvm flutter` / `fvm dart`.
- Run app: `fvm flutter run --dart-define-from-file=.env`
- Build APK: `fvm flutter build apk --dart-define-from-file=.env`
- Analyze: `fvm flutter analyze`
- Test: `fvm flutter test`
- Codegen: `fvm flutter pub run build_runner build --delete-conflicting-outputs`
- Localization: `fvm flutter gen-l10n`
- Dependencies: `fvm flutter pub get`

### Architecture

- Feature-first Clean Architecture under `lib/features/<feature>/`.
- Feature layering follows `presentation/`, `domain/`, and `data/` where implemented.
- Shared infrastructure lives under `lib/core/`.
- Domain repositories are abstract interfaces; data repositories implement them.
- Domain entities are pure Dart classes.
- Data models handle JSON/remote mapping.
- UI should read via BLoC/repository streams, not directly from Supabase.

### Folder structure

- `lib/app/`: app widget and `go_router` setup.
- `lib/core/di/`: `get_it` + `injectable` setup and modules.
- `lib/core/database/`: Drift `AppDatabase`, tables, DAOs, generated files, schema reference.
- `lib/core/sync/`: offline sync queue, sync service/cubit/widget.
- `lib/core/network/`: connectivity and weather services.
- `lib/core/utils/`: `Result`, `AppException`, `ErrorCode`, extensions.
- `lib/features/`: auth, project, diary, tasks, photos, floor_plan, reports, weather, settings, profile, onboarding.
- `lib/l10n/`: ARB files and generated localizations.
- `test/`: mirrors `lib/` structure for unit, bloc, DAO, widget tests.

### State management

- Uses `flutter_bloc`.
- BLoCs are `@injectable` factories and are provided per route/page with `BlocProvider`.
- App-wide/background Cubits/services such as `ConnectivityCubit`, `SyncStatusCubit`, `SyncService`, and `PhotoSyncService` are singletons where current code requires it.
- BLoC states/events use sealed classes, often with `part` for events.
- Error states carry `ErrorCode`, not user-facing strings.

### Widget conventions

- User-facing strings should come from `context.l10n` via `LocalizationX`.
- Errors should display `state.code.localize(context)`.
- Widgets use Material components, `Theme.of(context)`, `BlocBuilder`, `BlocListener`, or `BlocConsumer` depending on side effects.
- Navigation uses `context.go(...)` / `GoRouter.of(context).go(...)` with route paths from `lib/app/router.dart`.
- Private helper widgets/classes use leading underscore in screen files when local to a screen.

### Data/network conventions

- Drift is the local source of truth.
- Writes should go to local Drift first, then attempt remote or enqueue sync depending on feature implementation.
- Supabase is used for auth, Postgres, and storage.
- Sync queue entries are created via `OfflineFirstRepository.enqueueSync()` / `SyncQueueDao`.
- Connectivity is represented by `ConnectivityCubit` and `ConnectivityState.online/offline`.
- Storage bucket convention for photos is `project-files`, with local copies stored before upload.
- `schema_reference.sql` is the schema source of truth; local-only Drift columns are marked `[LOCAL ONLY]`.

### Routing

- Router is created in `lib/app/router.dart` with `createRouter(AuthBloc)`.
- Initial location is `/home`.
- Auth/onboarding/profile setup redirects are handled in router redirect logic.
- Existing routes include `/login`, `/forgot-password`, `/reset-password`, `/profile-setup`, `/home`, `/projects`, `/projects/new`, `/projects/:id`, `/projects/:id/diary`, `/projects/:id/diary/new`, `/projects/:id/tasks`, `/projects/:id/tasks/new`, `/projects/:id/tasks/:taskId/edit`, `/settings`.
- Route builders wrap screen-level BLoCs with `BlocProvider` where needed.

### Error handling

- Use native Dart sealed `Result<T>` with `Success<T>` and `Failure<T>`.
- Repositories/data sources return `Future<Result<T>>` for fallible operations.
- Exceptions use `AppException` subclasses and `ErrorCode`.
- Catch-all handlers log via `dart:developer` `log(..., error: e, stackTrace: st)` and wrap as `UnknownException(st)`.
- Presentation localizes via `ErrorCodeL10n.localize(context)`.
- Adding an `ErrorCode` requires matching ARB keys and extension cases.

### DI

- Uses `get_it` and `injectable`.
- `configureDependencies()` calls generated `getIt.init()`.
- `AppDatabase` is `@singleton` via `DatabaseModule`.
- Repositories use `@LazySingleton(as: Interface)`.
- Data sources and DAOs are lazy singletons where current modules show that pattern.
- BLoCs are `@injectable` factory registrations.
- After DI changes, run build_runner.

### Testing conventions

- Uses `flutter_test`, `mocktail`, and `bloc_test`.
- Tests mirror source paths under `test/`.
- BLoC tests use `blocTest` and mock repositories/context.
- Repository tests mock DAOs, remote data sources, Supabase auth/client collaborators, and verify Drift-first/sync behavior.
- DAO/sync tests use current helpers and in-memory Drift patterns where present.

### Validation checklist

- For context-only changes: verify generated Markdown files contain no secrets/private URLs and stay within allowed paths.
- For future code changes: run `fvm flutter analyze` and `fvm flutter test` before completion.
- Run `fvm flutter gen-l10n` after ARB changes.
- Run build_runner after Drift/injectable/generated-code-affecting changes.
- Preserve user-owned existing changes; current repo has a pre-existing modified `pubspec.lock` that this task must not touch.

### Differences from global defaults

- Always use `fvm flutter`/`fvm dart` because `.fvmrc` exists.
- Do not rely on README as authoritative; it is still the default Flutter template.
- Repo-specific `CLAUDE.md` and nested feature/module `CLAUDE.md` files are authoritative source material for Factory context.
- Do not create/update generic documentation outside allowed Factory context files for this task.
- Do not introduce repo-specific skills/droids unless explicitly needed later.
- Flutter commands are exempt from `rtk` output filtering per global instructions.
- Commit-message global co-author/signoff preferences conflict with developer defaults; repo/global user preference says no AI co-authorship/signoff in commit messages.

## 4. Risks/uncertainties

- `README.md` is generic and outdated, so the generated context will rely on code, `pubspec.yaml`, `CLAUDE.md`, and nested feature `CLAUDE.md` files instead.
- Current repository already has a modified `pubspec.lock`; it will be left untouched.
- Some feature barrel files (`reports.dart`, `floor_plan.dart`, etc.) are placeholders; context will describe them only as present, not implemented.
- Some current code contains placeholder routes/widgets (for example onboarding/settings placeholders); context should record actual state without claiming completion.
- Generated localization files exist in `lib/l10n/generated`; context should not suggest editing them manually.
- No secrets were read; `.env` must remain uninspected/uncommitted.

## 5. Validation plan

Because this task only creates Factory context Markdown and does not modify app code/tests/dependencies:

1. Create the proposed files only under allowed paths.
2. Re-read each created file to verify:
   - No secrets, credentials, private URLs, tokens, temporary machine-specific details, or redacted values.
   - No production/test/dependency files changed.
   - Commands and conventions match observed code.
   - Existing `CLAUDE.md` guidance is preserved and not contradicted.
3. Run read-only repository checks:
   - `git status --porcelain` to confirm only allowed context files were added/updated plus the pre-existing `pubspec.lock` modification.
   - `git diff -- AGENTS.md .factory/memories.md .factory/rules/flutter.md .factory/rules/architecture.md .factory/rules/validation.md` to review exact generated content.
4. Skip `fvm flutter analyze` and `fvm flutter test` for this context-only Markdown task unless implementation unexpectedly touches Dart/config files, which it will not.

## Implementation steps after approval

1. Create `.factory/` and `.factory/rules/` directories.
2. Write `AGENTS.md` with concise repo-specific instructions and pointers to rules.
3. Write `.factory/memories.md` with durable facts inferred from the repository.
4. Write `.factory/rules/flutter.md` with Flutter, BLoC, localization, routing, testing, and command conventions.
5. Write `.factory/rules/architecture.md` with data flow, Drift/Supabase, DI, sync, storage, and error-handling conventions.
6. Write `.factory/rules/validation.md` with validation commands and checklist.
7. Verify with file reads, `git status --porcelain`, and targeted `git diff`.