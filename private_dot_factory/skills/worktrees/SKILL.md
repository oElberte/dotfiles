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

Always create worktrees inside the repository root under `.worktrees/`.

- Required path shape: `<repo-root>/.worktrees/<short-name>`.
- Never create sibling worktrees next to the repo.
- Never create worktrees under `/tmp`, `$HOME`, a parent workspace, or another external directory.
- If the repo root cannot be determined or `.worktrees/` cannot be used safely, stop and ask before continuing in-place or choosing another path.

Before creating the worktree, verify the repo-local folder is ignored:

```bash
git -C "<repo-root>" check-ignore -q .worktrees/
```

If not ignored, add `.worktrees/` to the repo's local exclude file before creating the worktree:

```bash
printf '\n.worktrees/\n' >> "<repo-root>/.git/info/exclude"
```

Do not create the worktree until `.worktrees/` is ignored.

## Creation

```bash
branch="task/short-name"
repo_root="$(git rev-parse --show-toplevel)"
path="$repo_root/.worktrees/short-name"
git -C "$repo_root" worktree add "$path" -b "$branch"
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
repo_root="$(git rev-parse --show-toplevel)"
git -C "$repo_root" worktree remove "$repo_root/.worktrees/short-name"
git -C "$repo_root" branch -d "task/short-name"
```

## Guardrails

- Never create worktrees outside `<repo-root>/.worktrees/`.
- Never create worktrees in a tracked directory.
- Never clean/delete a worktree with uncommitted user work without explicit approval.
- Never merge without showing status/diff and receiving approval.
- Do not use worktrees to bypass repo validation.
- Do not clean up a worktree just because validation passed; user chooses completion path.
