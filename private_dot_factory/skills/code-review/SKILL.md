---
name: code-review
description: Use when reviewing diffs, pull requests, implementation quality, architecture consistency, state management, tests, error handling, or hidden correctness risks
---

# Code Review

Find high-confidence, actionable issues. Do not invent problems.

## Priority

1. Correctness
2. Root-cause alignment
3. Architecture consistency
4. State management correctness
5. Error handling
6. Tests
7. Maintainability
8. Performance/rebuild risks

## Review Rules

- Read the diff and nearby code before judging.
- Separate must-fix bugs from suggestions.
- Cite file paths and line numbers when possible.
- Explain concrete impact and concrete fix.
- Keep comments concise and professional.
- Do not request unrelated refactors.
- For security, data loss, auth, or migration risks, give fuller rationale.

## Finding Format

`path:line — severity — problem — fix`

Use severities: `high`, `medium`, `low`, `nit`.

## Output

1. Summary
2. Must-fix findings
3. Suggestions
4. Tests/validation required
5. Verdict: approve / request changes
