# Personal Droid Notes

I like short, practical work. Read the repo, make the smallest clean change, and show proof before calling something done.

## How to work

- Be direct. No filler, no ceremony.
- Fix root causes, not symptoms.
- No hacks, monkey patches, fake fixes, or "temporary" workarounds.
- Follow the repo's style before my preferences.
- Do not refactor unrelated code.
- If a choice changes architecture, persistence, auth, security, or scope, ask first.

## Tools

- Use Context7 when library/API details matter and it is available.
- At the start of deeper repo work, check whether CodeGraph is available. If it is not initialized, suggest `codegraph init` or `npx -y @colbymchenry/codegraph init`.
- Prefer `frun` for noisy shell commands when available. It uses RTK when available and falls back to the raw command.
- Do not wrap commands where exact output matters: tests, analyzers, Dart, Flutter, or FVM.

## Git

- Protect user work. Check status before staging, committing, merging, or cleaning.
- Treat untracked files as user-owned.
- Never push unless I explicitly ask.
- Commit messages must be English Conventional Commits.
- Never add attribution or trailers: no `Co-authored-by`, no `Signed-off-by`, no bot names, no noreply addresses, no model names, no AI signatures.
- Never use the word "Claude" in commit messages.

## Worktrees

Use repo-local worktrees for risky or multi-step implementation:

```text
<repo-root>/.worktrees/<short-name>
```

Make sure `.worktrees/` is in `.git/info/exclude`. Do not create sibling, `/tmp`, or home-directory worktrees.

## Flutter

- Repo patterns win.
- If `.fvmrc` or `.fvm/` exists, use `fvm flutter` and `fvm dart`.
- Keep business logic out of widgets.
- Prefer small, composable, theme-aware widgets.
- BLoC/Cubit is my default only when the repo does not already have a clear different pattern.
- When codegen is involved, run codegen before analyze/tests.

## Model flow

Use a small routed flow. The current main model orchestrates, keeps context, and gives the final answer. Do not build a jury unless the work is genuinely risky.

- Use `coder` as the default implementation worker when delegating focused code changes.
- Use `principal` for architecture, hard bugs, failed validation loops, security/auth/data/migration risk, broad refactors, escalation, and final-judge passes.
- Use `frontend-polish` for visual UI/frontend taste: screens, widgets, layout, styling, responsive polish, and design-system fit.
- Use `frontend-escalation` only rarely for hard redesigns, stubborn visual/product issues, or a failed `frontend-polish` pass.
- Use `git-spark` for quick status/diff/commit-message chores when useful.
- Pass compact artifacts, not full transcripts.

## Writing Markdown

When creating `.md` files, keep them short, concise, and human-written. Make them feel like useful notes, not machine policy. Only write more when I ask or when clarity would suffer.

## Before finishing

Run the narrowest useful validation. If you cannot run it, say why and name the command I should run.

Final coding reports should be compact:

1. Changed
2. Validated
3. Risks/uncertainties
4. Next action, only if needed
