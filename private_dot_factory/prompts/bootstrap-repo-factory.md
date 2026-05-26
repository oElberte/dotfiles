# Bootstrap Factory Context For Current Repository

Create or update repo-specific Factory context in the current repository.

## Allowed Files

- `AGENTS.md`
- `.factory/memories.md`
- `.factory/rules/*`
- `.factory/skills/*`
- `.factory/droids/*`

## Safety

- Do not change production code.
- Do not change tests.
- Do not change dependencies.
- Do not invent conventions.
- Infer from the actual codebase.
- Repo-specific rules override global rules.
- Keep secrets, credentials, private URLs, and temporary details out of generated files.

## Document

- project overview
- run/build/test/analyze commands
- codegen commands
- architecture
- folder structure
- state management
- widget conventions
- data/network conventions
- routing
- error handling
- DI
- testing conventions
- validation checklist
- differences from global defaults

## Output

1. Proposed repo context structure
2. Files to create/update
3. Exact conventions inferred from code
4. Risks/uncertainties
5. Validation plan

Start in planning mode. Do not write until the plan is approved.

## End-of-Flow Privacy Gate

After creating or updating `.factory/`, before committing, merging, or finalizing, ask:

> Should `.factory/` be committed to this repository, or should it remain local-only for your personal usage?

If the user chooses local-only:

- Add `.factory/` to `.git/info/exclude`, not `.gitignore`.
- If `.factory/` is staged, unstage it.
- If `.factory/` is already tracked, explain that local exclude does not untrack committed files and ask before removing it from the git index or history.

If the user chooses committed:

- Keep `.factory/` trackable and show the diff before any commit.

Always report whether `.factory/` is tracked, untracked, ignored, or local-only.
