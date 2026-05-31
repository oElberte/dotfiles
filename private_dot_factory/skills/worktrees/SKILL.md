---
name: worktrees
description: Use when starting implementation, debugging, review fixes, experiments, or parallel tasks that benefit from isolated branches or multiple simultaneous workspaces
---

# Worktrees

Prefer git worktrees for nearly all implementation work. They let multiple tasks run at once without switching branches or dirtying the main checkout.

## When to use

- Parallel tasks
- Feature branches
- Risky refactors
- Bug investigations
- Review-fix loops
- Experiments that may be discarded
- Any repo where the user prefers worktrees by default

Default to using worktrees for implementation, debugging, and review fixes.

Skip only when:

- The task is a tiny local config edit.
- The change is explicitly meant for the current checkout.
- The user asks to work in-place.
- The repo cannot safely create a worktree and the user approves continuing in-place.

## Directory choice

Use this priority:

1. Repo-root `.worktrees/` folder.
2. Repo instruction file preference, only if it explicitly overrides the user's preference.
3. Ask the user.

For project-local worktree folders, verify they are ignored:

```bash
git check-ignore -q .worktrees
```

If not ignored, ask before modifying ignore files. Prefer `.git/info/exclude` for personal-only ignores.

Do not create sibling worktrees next to the repo by default. Do not create a project-local worktree until the `.worktrees/` parent directory is ignored or the user explicitly chooses another path.

## Creation

```bash
branch="task/short-name"
path=".worktrees/short-name"
git worktree add "$path" -b "$branch"
```

Then work from the worktree path.

## Baseline

Before editing:

1. Install/download dependencies only if needed.
2. Run the narrowest relevant baseline validation.
3. Record existing failures instead of fixing unrelated issues.

If baseline validation fails, stop and ask whether to continue, investigate, or switch task.

## Finish

1. Verify changes in the worktree.
2. Show diff and status.
3. Ask whether to merge, keep branch, create PR, or discard.
4. Use `branch-completion`.
5. Remove worktree only after user-approved integration or explicit discard:

```bash
git worktree remove ".worktrees/short-name"
git branch -d "task/short-name"
```

## Guardrails

- Never create project-local worktrees in a tracked directory.
- Never clean/delete a worktree with uncommitted user work without explicit approval.
- Never merge without showing status/diff and receiving approval.
- Do not use worktrees to bypass repo validation.
- Do not clean up a worktree just because validation passed; user chooses completion path.
