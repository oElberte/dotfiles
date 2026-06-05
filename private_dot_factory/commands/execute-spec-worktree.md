---
description: Execute a spec or plan end-to-end in a worktree with detailed validation
argument-hint: [spec/plan path or task context]
---

Start and execute this spec or plan end-to-end: `$ARGUMENTS`.

Do each task with strong attention to detail and correctness. Focus on making the implementation work well in the real app, not just on completing checklist items.

Work continuously until the spec or plan is finished, unless you are blocked or need my input. Do not stop for routine checkpoints.

Test and validate as you develop so each change is proven to work in the app. Use the right runtime tools for the surface:

- Web apps: use Playwright/browser automation for navigation, forms, screenshots, visual checks, console errors, network requests, and user-flow regression testing.
- APIs/services: use HTTP requests, fetch/curl-style checks, logs, and focused integration tests to validate responses, contracts, auth behavior, errors, and edge cases.
- Scraping/rendered-content flows: verify real rendered content, links, metadata, selectors, pagination, empty states, and failure states instead of only checking static code.
- Flutter/mobile apps: use Flutter tests plus emulator/device tooling such as `adb` for installing/running builds, viewing device state, taking screenshots, tapping through flows, checking logs, and validating behavior on real screens.
- Screenshots and visual artifacts: save them under `docs/screenshots/` and follow the repository's screenshot artifact guidance before adding excludes or tracking files.

Work inside a git worktree located at the repository root under `.worktrees/`.
Do not create sibling or external worktrees.

Use the repository's existing conventions and validation commands. If you need anything else from me, ask clearly.
