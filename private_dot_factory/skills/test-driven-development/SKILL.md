---
name: test-driven-development
description: Use when implementing features, bug fixes, behavior changes, or refactors where test-first discipline prevents regressions and clarifies intent
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass.

## When to use

- New features
- Bug fixes
- Behavior changes
- Refactors where behavior must be preserved

Skip for generated code, throwaway prototypes, or config-only changes. Skip when the repo's test framework is broken or the user asks to skip.

## RED-GREEN-REFACTOR

### RED — Write the failing test

Write one minimal test showing what should happen.

- Clear name describing behavior.
- One behavior per test.
- Use real objects over mocks when practical.
- Match the repo's test patterns.

### Verify RED — Watch it fail

Run the test. Confirm:

- It fails, not errors.
- The failure message is expected.
- It fails because the feature is missing, not due to a typo.

If it passes without implementation, the test is wrong.

### GREEN — Minimal code

Write the simplest code to pass the test. No extra features. No refactoring yet.

### Verify GREEN — Watch it pass

Run the test. Confirm it passes and no other tests break.

### REFACTOR — Clean up

After green only: remove duplication, improve names, extract helpers. Keep tests green. Do not add behavior.

### Repeat

Next failing test for next behavior.

## When things go wrong

- Test passes immediately → you are testing existing behavior or wrote a weak test. Fix the test.
- Test errors → fix the error, re-run until it fails correctly.
- 3+ fixes don't work → stop and question assumptions. Do not keep piling on fixes.

## Integration with pipeline

For multi-step plans, TDD applies per task. Write failing test → implement → verify → move to next task.
