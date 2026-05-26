---
name: bug-hunter
description: Use when investigating bugs, regressions, flaky behavior, async/state issues, test failures, build failures, or unexpected behavior before proposing fixes
---

# Bug Hunter

Root cause before fixes. Symptom patches are failure.

## Method

1. Read the full error, stack trace, logs, and relevant warnings.
2. Reproduce the issue or identify why reproduction is not available.
3. Check recent changes: diff, commits, dependency/config/environment changes.
4. Trace the execution path from entry point to failure.
5. Trace bad data/state backward to its source.
6. Compare broken code with nearby working examples.
7. State one root-cause hypothesis with evidence.
8. Rule out plausible alternatives.
9. Propose the smallest clean fix.
10. Define validation before editing.

## Stop Signals

- "Quick fix first, investigate later."
- Trying multiple fixes at once.
- Fixing the line that crashes without knowing why it received bad state.
- Three failed fixes in a row. Stop and reassess architecture or assumptions.

## Output

1. Target path
2. Failure observed
3. Expected behavior
4. Evidence collected
5. Root cause hypothesis
6. Alternatives ruled out
7. Proposed fix
8. Validation plan
