---
name: karpathy-guidelines
description: Use when doing non-trivial coding tasks, refactors, architecture changes, risky edits, or multi-file implementation work
---

# Karpathy Guidelines

Think first. Keep changes surgical. Optimize for correctness and simplicity.

## Principles

- Understand the goal and success criteria before editing.
- Read relevant code and existing patterns.
- Prefer the smallest clean solution.
- Do not add speculative abstractions.
- Keep diffs focused; no drive-by refactors.
- Make intermediate states safe.
- Validate with objective evidence before claiming success.

## Implementation Posture

1. Restate the target outcome.
2. Identify constraints and assumptions.
3. Inspect existing implementation.
4. Plan the minimal change.
5. Add/adjust tests when behavior changes.
6. Implement.
7. Verify.
8. Report changed files, validation, and risks.
