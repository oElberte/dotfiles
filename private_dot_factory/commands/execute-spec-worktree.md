---
description: Execute or resume a spec/plan end-to-end in a worktree with checklist tracking
argument-hint: [spec/plan path or task context] [resume/continue notes]
---

Start or continue executing this spec or plan end-to-end: `$ARGUMENTS`.

Interpret `$ARGUMENTS` as both the spec/plan source and any execution instructions. Examples:

- `/execute-spec-worktree docs/plans/feature.md`
- `/execute-spec-worktree docs/plans/feature.md continue from the existing worktree`
- `/execute-spec-worktree docs/plans/feature.md there is already work done, resume where it left off`

If the arguments mention continuing, resuming, already-started work, or work already done:

1. Prefer the existing worktree for this spec/plan instead of creating a new one.
2. Inspect the repository's worktrees, current branches, `git status`, and relevant diffs before editing.
3. If exactly one existing worktree clearly matches the plan, continue there.
4. If multiple worktrees could match, ask me which one to use.
5. If no existing worktree matches, ask before creating a new one unless the arguments explicitly allow it.

Do each task with strong attention to detail and correctness. Focus on making the implementation work well in the real app, not just on completing checklist items.

Work continuously until the spec or plan is finished, unless you are blocked or need my input. Do not stop for routine checkpoints.

Use the plan/spec file as the persistent progress tracker:

1. Before implementing, convert actionable plan items into markdown checkboxes if they are not already checkboxes.
2. Preserve the original plan content and wording as much as possible; only add checkbox markers and minimal progress notes when useful.
3. Treat checked items as already completed only after verifying they are actually implemented in the worktree.
4. Tick each checkbox as soon as that item is fully implemented and validated, not only at the end.
5. Never tick a checkbox for partial, untested, or blocked work.
6. If an item is blocked, leave it unchecked and add a short `Blocked:` note under that item.
7. When resuming, read the existing checkbox state first, inspect the worktree changes, reconcile any stale checkboxes, and continue from the first unchecked actionable item.
8. Before stopping, ensure the plan reflects the current state so the work can be resumed later.

Test and validate as you develop so each change is proven to work in the app. Use the right runtime tools for the surface:

- Web apps: use Playwright/browser automation for navigation, forms, screenshots, visual checks, console errors, network requests, and user-flow regression testing.
- APIs/services: use HTTP requests, fetch/curl-style checks, logs, and focused integration tests to validate responses, contracts, auth behavior, errors, and edge cases.
- Scraping/rendered-content flows: verify real rendered content, links, metadata, selectors, pagination, empty states, and failure states instead of only checking static code.
- Flutter/mobile apps: use Flutter tests plus emulator/device tooling such as `adb` for installing/running builds, viewing device state, taking screenshots, tapping through flows, checking logs, and validating behavior on real screens.
- Screenshots and visual artifacts: save them under `docs/screenshots/` and follow the repository's screenshot artifact guidance before adding excludes or tracking files.

Work inside a git worktree located at the repository root under `.worktrees/`.
Do not create sibling or external worktrees.

Use the repository's existing conventions and validation commands. If you need anything else from me, ask clearly.
