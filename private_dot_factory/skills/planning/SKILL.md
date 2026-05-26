---
name: planning
description: Use when starting non-trivial implementation, refactors, repo bootstraps, architecture changes, multi-file edits, or work that needs a clear plan before coding
---

# Planning

Plan enough to prevent drift. Do not over-process simple edits.

## When to use

- Multi-file or risky implementation
- Architecture or behavior changes
- Repo bootstrap/context generation
- Ambiguous requirements
- Work that should be split into tasks

Skip for one-file trivial edits unless the user asks for a plan.

## Process

1. Inspect current context first: files, conventions, commands, git state if relevant.
2. Define success criteria in plain language.
3. List assumptions and uncertainties.
4. Propose the smallest clean approach.
5. Identify exact files to create or modify.
6. Define validation commands before editing.
7. Ask only when a decision changes scope, safety, architecture, or persistence.

## Plan format

1. Goal
2. Current context
3. Proposed changes
4. Files touched
5. Validation
6. Risks/uncertainties

## Guardrails

- Repo-specific instructions override global preferences.
- Do not invent conventions.
- Do not include unrelated refactors.
- Do not force worktrees unless the repo/user prefers them or parallel work benefits.
- If using a worktree, follow the `worktrees` skill.
