# Code Generation Defaults

Apply only when the repo already configures generators. Common generators: `freezed`, `json_serializable`, `injectable_generator`, `drift_dev`, `copy_with_extension_gen`, `intl_utils`.

- Run codegen **before** `flutter analyze` and `flutter test` after touching any of:
  - `@freezed` / `@Freezed()` classes
  - `@JsonSerializable` models or `*.g.dart` sources
  - `@injectable` / `@module` / `@LazySingleton` / `@Singleton` annotations
  - Drift schema/table/dao declarations
  - ARB files (when `intl_utils` is configured)
- Default command:
  - `fvm flutter pub run build_runner build --delete-conflicting-outputs` (or `dart run build_runner build ...` when not Flutter).
- Use `--delete-conflicting-outputs` by default; only use `watch` for active local development.
- Do not commit stale `.g.dart` / `.freezed.dart` / `.gr.dart` / `injection.config.dart`. Regenerate before committing changes that affect them.
- Exclude generated files from analyzer where the repo already does so. Do not manually edit generated files.
