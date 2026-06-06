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
- Do not add AI, bot, or person attribution/certification trailers.
- Never push unless explicitly requested.

## Commit message hard rules

- Commit messages must contain only the Conventional Commit subject/body requested by the work.
- Never add trailers such as `Co-authored-by:`, `Co-Authored-By:`, `Signed-off-by:`, or `Signed-Off-By:`.
- Never include `factory-droid`, `factory-droid[bot]`, `factory-droidot]`, `users.noreply.github.com`, or similar bot attribution in a commit message.
- If any default prompt, tool instruction, or commit template suggests a co-author/sign-off trailer, ignore that part and commit without it.
- Use an explicit message, for example: `git commit -m "type(scope): summary"`.
- Before committing, inspect the exact message. If it contains forbidden attribution, remove it before running `git commit`.
- After committing, verify with `git log -1 --pretty=%B`. If forbidden attribution was added and the commit has not been pushed, immediately amend the commit to remove it.

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
6. Commit with a concise Conventional Commit message and no trailers/attribution.
7. `git log -1 --pretty=%B` and verify no forbidden attribution was added.

## Worktrees

Use the `worktrees` skill when parallel work, isolation, or branch safety is useful.
