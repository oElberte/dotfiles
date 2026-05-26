---
name: receiving-code-review
description: Use when applying, evaluating, or responding to code review feedback, requested changes, reviewer comments, or final-review findings
---

# Receiving Code Review

Treat review as evidence to verify, not orders to obey blindly.

## Process

1. Read the review comment and the referenced code.
2. Classify each item:
   - real bug
   - valid maintainability/test concern
   - preference/nit
   - unclear or likely incorrect
3. Verify claims against code, tests, and requirements.
4. For valid issues, apply the smallest clean fix.
5. For unclear issues, ask a focused question or propose an interpretation.
6. For incorrect issues, explain why with evidence.
7. Re-run relevant validation after fixes.

## Response format

For each finding:

- `accept` — issue is valid and fixed
- `push back` — issue is incorrect or out of scope, with evidence
- `clarify` — question needed before changing
- `defer` — valid but outside current scope

## Guardrails

- Do not make unrelated refactors while addressing review.
- Do not change behavior unless the review asks for it or the bug requires it.
- Do not silently ignore review findings.
- Keep comments professional and concise.
