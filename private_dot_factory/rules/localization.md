# Localization Defaults

Apply only when the repo already has an l10n setup. Do not introduce localization tooling unrequested.

- Never hardcode user-facing strings in widgets. All visible text must come from ARB-generated localizations.
- Prefer a `context.l10n` extension over calling generated classes directly in widgets:
  - `Text(context.l10n.someKey)` instead of `Text(S.of(context).someKey)` or `Text(AppLocalizations.of(context)!.someKey)`.
- Add new keys to every existing ARB locale file (e.g., `app_en.arb` and `app_pt.arb`), not just the primary locale.
- Use ARB placeholders for dynamic content; do not concatenate localized strings.
- After editing ARB files, regenerate localizations using the project's command (e.g., `fvm flutter gen-l10n` or `intl_utils`).
- Exclude generated localization files (`lib/l10n/generated/**`, `messages_*.dart`) from analyzer and import sorters when the repo configures them.
- Logs, exception messages, debug-only text, and developer-facing assertions do not need to be localized.
