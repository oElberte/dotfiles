---
name: git-workflow
description: Use when checking git state, staging, committing, merging, creating branches, using local excludes, or deciding whether files should be tracked
---

# Git Workflow

Protect user work. Be explicit about what is tracked, staged, ignored, committed, and pushed.

## Rules

- Run `git status --porcelain` before operations that depend on working-tree state.
- Treat untracked files as user-owned.
- Never delete, overwrite, move, or clean untracked files unless explicitly requested.
- Before commits, inspect `git diff --cached` and `git status`.
- Do not commit secrets, `.env`, credentials, logs, build outputs, or private local config.
- Use Conventional Commits in English.
- Do not add AI attribution, `Co-authored-by`, or `Signed-off-by`.
- Never push unless explicitly requested.

## Local-only files

When a file/folder should be ignored only for the current user/repo:

```bash
printf '\n.factory/\n' >> .git/info/exclude
```

Use `.git/info/exclude`, not `.gitignore`, for personal-only ignores.

If a file is already tracked, local excludes do not untrack it. Ask before running:

```bash
git rm --cached -r .factory
```

## Commit checklist

1. `git status --porcelain`
2. Review unstaged and staged diffs.
3. Stage only intended files.
4. `git diff --cached`
5. Check for secrets and unrelated changes.
6. Commit with concise Conventional Commit message.

## Worktrees

Use the `worktrees` skill when parallel work, isolation, or branch safety is useful.
