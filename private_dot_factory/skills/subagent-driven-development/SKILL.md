---
name: subagent-driven-development
description: Use when an implementation plan has 2+ independent tasks that can run in parallel, or when delegating research/exploration/code-review to specialized droids
---

# Subagent-Driven Development

Dispatch independent tasks to subagents for parallel execution.

## When to use

- A plan has 2+ tasks that don't depend on each other's output.
- A task is self-contained (one file, one feature, one concern).
- You need parallel research, exploration, or data gathering.
- A specialized droid (flutter-reviewer, bug-hunter, worker, mid-dev) fits the task better.

## When NOT to use

- A single spec/plan needs the full quality pipeline (plan-reviewer → coder → final-reviewer). Use the multi-agent pipeline from AGENTS.md instead.
- Tasks have strict sequential dependencies.
- The task is trivial (one-file <20-line edit).

## Process

1. Identify independent tasks from the plan.
2. For each task, choose:
   - **worker/mid-dev**: routine implementation, file edits, git operations.
   - **flutter-reviewer**: read-only Flutter/BLoC/widget review.
   - **bug-hunter**: root-cause investigation.
   - **plan-reviewer/coder/final-reviewer**: only for pipeline tasks, not generic work.
3. Dispatch tasks in parallel via `Task` tool.
4. Collect results. Each subagent returns: summary, files changed, validation, blockers.
5. Sequence dependent tasks based on results.

## Task format

Each dispatch must include:

- Goal
- Exact file paths and constraints
- What to avoid
- Expected output and format
- Validation commands

## Review

After all parallel tasks complete:

1. Review each subagent's output.
2. Verify each subagent's validation claims when reasonable.
3. Run integration validation if tasks intersect.
4. Report: what was done, what passed, what needs follow-up.

## Guardrails

- Subagents work in the same repo/branch; avoid race conditions on shared files.
- If two tasks touch the same file, serialize them.
- Do not dispatch a subagent to do work you should verify yourself.
- Never commit or push from subagents without parent approval.
- If the plan calls for the pipeline (plan-reviewer → coder → final-reviewer), use the pipeline, not subagent-driven.
