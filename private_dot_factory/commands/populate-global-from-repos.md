# Populate Global Factory Context From Flutter Repos

Inspect all Flutter repositories listed in `/home/dev/.factory/flutter-repos.txt` and improve only global Factory Droid context under `/home/dev/.factory`.

Use `/home/dev/.factory/prompts/populate-global-from-repos.md` as the source prompt and follow it strictly.

## Required behavior

- Read `/home/dev/.factory/flutter-repos.txt`.
- Inspect each listed repository.
- Do not modify any repository listed in `flutter-repos.txt`.
- Only create or update files under `/home/dev/.factory`.
- Do not include secrets, credentials, private URLs, client-sensitive details, `.env` contents, or temporary project facts.
- Do not invent conventions.
- Promote patterns to global defaults only when they repeat across multiple repos or match stable stated preferences.
- Convert conflicting repo patterns into conditional rules, not hard rules.
- Keep global files as defaults; repo-specific `AGENTS.md` and `.factory/*` remain the truth.

## Inspect

- `pubspec.yaml`
- `analysis_options.yaml`
- README/project docs
- `lib/`
- `test/`
- `integration_test/`
- scripts and CI configs
- architecture
- state management
- DI
- routing
- localization
- networking/data layer
- theme/design system
- widgets
- BLoC/Cubit
- testing and validation patterns

## Output

1. Repositories inspected
2. Repeated patterns found
3. Global files proposed/updated
4. Conflicts kept conditional
5. Secrets/privacy checks
6. Validation performed
