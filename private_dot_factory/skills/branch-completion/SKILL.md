---
name: branch-completion
description: Use when implementation is finished and the user must choose merge, PR, keep branch, discard, cleanup, or local-only handling
---

# Branch Completion

Finish work deliberately. Do not merge or clean up without the user's choice.

## Before presenting options

1. Run `verification` for the completed work.
2. Inspect `git status --porcelain`.
3. Inspect staged/unstaged diffs as relevant.
4. Check for unrelated or pre-existing changes.
5. Check whether generated/context files should be committed or local-only.

## Present choices

Offer the relevant options:

1. Merge locally
2. Create PR
3. Keep branch/worktree for later
4. Discard branch/worktree
5. Make selected files local-only via `.git/info/exclude`

Recommend one option and explain why briefly.

## If merging locally

1. Show status/diff summary.
2. Confirm intended branch and target branch.
3. Commit if needed, following `git-workflow`.
4. Merge only after explicit user approval.
5. Run or cite final validation.

## If using worktrees

Before cleanup:

1. Confirm worktree has no uncommitted user work.
2. Confirm branch is merged, intentionally kept, or intentionally discarded.
3. Remove worktree only after approval.

```bash
git worktree remove "<path>"
git branch -d "<branch>"
```

Use `git branch -D` only if the user explicitly approves discarding unmerged work.

## Guardrails

- Never push without explicit request.
- Never delete a branch/worktree with uncommitted or unmerged work unless explicitly approved.
- Never silently commit `.factory/`; ask whether it should be committed or local-only.
- Never hide pre-existing dirty state.
