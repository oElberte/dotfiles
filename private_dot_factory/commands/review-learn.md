---
description: Address a PR's review comments and failing CI, then learn durable conventions from the feedback into your .factory knowledge base.
argument-hint: '<PR-number> | <PR-URL>'
---

Load skill: **address-pr-and-learn**.

The argument is a pull request reference: `$ARGUMENTS`

- Bare number (e.g. `4521`) → operate on the PR in the current repository.
- Full URL (e.g. `https://github.com/owner/repo/pull/4521`) → extract `owner/repo/number`.

Run the full two-phase workflow defined in the skill:

1. **Address** — fix the code for each reviewer finding and each failing CI check (automatic). Do **not** push or reply to reviewers without explicit permission; instead hand me the draft reply text to paste, or push/reply only after I confirm.
2. **Learn** — extract generalizable conventions, preferences, and architectural rules from the feedback and propose entries for the appropriate `MEMORIES.md` (and, when warranted, `AGENTS.md`/rules). Write nothing until I approve the proposed entries.
