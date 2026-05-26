---
name: plan-execution
description: Use when executing an approved plan, checklist, spec, implementation roadmap, repo bootstrap, or multi-step task with review checkpoints
---

# Plan Execution

Execute plans faithfully. Do not redesign during implementation.

## Before editing

1. Read the full plan/spec/checklist.
2. Confirm the current repo, branch, and working-tree state.
3. Use the `worktrees` skill unless this is a tiny config edit or the user asks to work in-place.
4. Identify files each step may touch.
5. Identify validation commands.
6. Stop and ask if the plan conflicts with repo instructions or user constraints.

## Execution loop

For each task:

1. Mark the task in progress.
2. Read nearby code/config before editing.
3. Apply only the planned change.
4. Run the narrowest relevant validation.
5. Fix failures caused by the change.
6. Update task status.
7. Continue to the next task.

## When blocked

Stop and report:

1. Current task
2. Exact blocker
3. Evidence gathered
4. Options with recommendation

Do not invent workarounds or expand scope silently.

## Completion

1. Re-read the original goal/plan.
2. Verify each requirement is covered.
3. Run final validation.
4. Show git status and diff summary.
5. Use `branch-completion` before merge, PR, cleanup, or final handoff.

## Guardrails

- No unrelated refactors.
- No unplanned architecture changes.
- No success claims without `verification`.
- No commits, merges, pushes, or worktree cleanup without explicit user direction.
