# Populate Global Factory Context From Flutter Repos

Inspect Flutter repositories listed in `/home/dev/.factory/flutter-repos.txt` and improve only global Factory files under `/home/dev/.factory`.

## Safety

- Do not modify repositories.
- Only create or update files under `/home/dev/.factory`.
- Do not include secrets, credentials, private URLs, client-sensitive details, or temporary project details.
- Do not invent conventions.
- Promote a pattern to global only if it repeats across multiple repos or matches stable stated preferences.
- Conflicting patterns must become conditional rules, not hard rules.
- Keep global rules as defaults; repo-specific files remain the truth.

## Repo discovery

For each path in `flutter-repos.txt`:

1. If the path has a `pubspec.yaml` at its root, treat it as one Flutter repo.
2. If the path does NOT have a `pubspec.yaml` at its root, search one level of subdirectories for `pubspec.yaml` files and treat each matching subdirectory as a separate Flutter repo (modular monorepo).
3. Skip paths with zero Flutter projects found.

## Inspect Per Repo

- `pubspec.yaml`
- `analysis_options.yaml`
- README or equivalent project docs
- `lib/`
- `test/`
- `integration_test/`
- scripts and CI configs
- architecture and folder structure
- state management
- DI
- routing
- networking/data layer
- theme/design system
- widgets
- BLoC/Cubit usage
- testing patterns

## Output

1. Repositories inspected (with count)
2. Repeated patterns found
3. Proposed global updates
4. Files to update under `/home/dev/.factory`
5. Risks/uncertainties
6. Validation plan

Start in planning mode. Do not write until the plan is approved.
