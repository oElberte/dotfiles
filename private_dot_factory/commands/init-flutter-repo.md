# Init Flutter Repo Factory Context

Initialize repo-specific Factory Droid context for the current Flutter repository.

Use `/home/dev/.factory/prompts/bootstrap-repo-factory.md` as the source prompt and follow it strictly.

## Required behavior

- Work in the current repository only.
- Start in planning mode unless the user explicitly requests writing.
- Inspect the actual codebase before proposing conventions.
- Do not change production code, tests, dependencies, generated files, or environment files.
- Create/update only:
  - `AGENTS.md`
  - `.factory/memories.md`
  - `.factory/rules/*`
  - `.factory/skills/*`
  - `.factory/droids/*`
- Do not invent conventions.
- Keep secrets, credentials, private URLs, `.env` contents, and temporary details out of generated files.
- Preserve existing repository instructions, including `CLAUDE.md`, nested instruction files, and existing `.factory` files.

## End-of-flow privacy gate

After generating or updating `.factory/`, before committing, merging, or finalizing, ask:

> Should `.factory/` be committed to this repository, or should it remain local-only for your personal usage?

If the user chooses local-only:

- Add `.factory/` to `.git/info/exclude`, not `.gitignore`.
- If `.factory/` is staged, unstage it.
- If `.factory/` is already tracked, explain that local exclude does not untrack committed files and ask before removing it from git history/index.

If the user chooses committed:

- Keep `.factory/` trackable and show the diff before any commit.

Always report:

1. Files created/updated
2. Whether `.factory/` is tracked, untracked, ignored, or local-only
3. Validation performed
