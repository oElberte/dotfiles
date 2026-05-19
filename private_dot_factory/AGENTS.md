# Global Rules

## RTK (Rust Token Killer) — Command Proxy

**Always prefix shell commands with `rtk`** — this proxies output through RTK's token-optimizing filter, reducing context pollution by 60-90%.

This applies to ALL commands run via Execute, including in chains:

```bash
rtk git add . && rtk git commit -m "msg" && rtk git push
rtk npm install && rtk npm run build
```

### Exceptions — keep raw output for these

- **Test runners**: `dart test`, `flutter test`, `pytest` (need exact failure details)
- **Lint/analyze**: `flutter analyze`, `dart analyze` (need exact diagnostics)
- **Dart/Flutter tooling**: `dart`, `flutter`, `fvm flutter`, `fvm dart` (tool protocol)

### Meta commands

```bash
rtk gain              # Check token savings
rtk gain --history    # Command history with savings
```

### Fallback

If `rtk` is not found on the system, fall back to raw command execution.

## Context & Tools

Always use Context7 when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

## Git

Never sign commits as an AI or as anyone. Nothing of 'Co-Authored By' or 'Signed-Off-By' in commit messages.
Never use the word "Claude" in commit messages.
Use conventional commits standard.
Commit messages must be in English.

## Code Style

Prefer concise, direct responses — no excessive explanations unless asked.
When suggesting fixes, show only the relevant changed code, not the entire file.
Never add comments explaining what the code does unless explicitly asked.

## Multi-agent pipeline (plan-reviewer, coder, final-reviewer)

### When to use it (mandatory trigger)

The parent session (Opus) must NEVER implement an approved spec directly.
As soon as `ExitSpecMode` is approved, or the user asks to "execute /
implement / run / proceed with the plan" referring to a spec file, you
MUST run the pipeline below. The only exceptions are:

- The user explicitly says "skip the pipeline", "do it yourself",
  "single agent", or similar.
- The change is a one-file, <20-line trivial edit (typo, rename, comment,
  config tweak) — in that case, ask the user whether to skip.

If unsure whether the task qualifies, ASK before coding.

### Pipeline order (always via the `Task` tool)

1. `Task(subagent_type="plan-reviewer", ...)` — pass the spec file path.
   Wait for it to return; if it edited the plan in place, re-read the
   updated plan before continuing.
2. `Task(subagent_type="coder", ...)` — pass the (now reviewed) spec file
   path. The coder must run lint / typecheck / tests and only return
   when verification passes.
3. `Task(subagent_type="final-reviewer", ...)` — read-only review of the
   coder's work against the original plan. Returns APPROVE or
   REQUEST_CHANGES with findings.

The parent session orchestrates only — it does not edit code itself
during the pipeline.

### Operating rules

- Goal check before declaring done: re-read the original goal from the
  brainstorm and spec. Explicitly state whether anything from the
  brainstorm that didn't make it into the spec/plan was honored, missed,
  or worth surfacing. Wait for user confirmation before claiming complete.
- Review loop bounds: if final-reviewer returns REQUEST_CHANGES, dispatch
  findings to coder and re-review. After 2 iterations without convergence,
  or if the same finding survives 2 coder passes, STOP and escalate to
  the user with a summary. Never loop indefinitely.

## Flutter

If the project contains an `.fvmrc` file or a `.fvm/` directory, always use `fvm flutter` and `fvm dart` instead of calling `flutter` or `dart` directly in any shell command.

## Personal Factory Context

Global defaults live in:

- `/home/dev/.factory/memories.md`
- `/home/dev/.factory/rules/*`
- `/home/dev/.factory/skills/*`
- `/home/dev/.factory/droids/*`
- `/home/dev/.factory/prompts/*`

Repository-specific `AGENTS.md`, project `.factory/rules/*`, project `.factory/skills/*`, and explicit user instructions override these global defaults when they conflict.

Do not force global Flutter/BLoC preferences into repositories that clearly use different architecture, state management, testing tools, or conventions.

## Non-Negotiable Engineering Rules

- Do not introduce hacks, monkey patches, fake fixes, or temporary workarounds.
- Do not commit partial implementations that may break later.
- Prefer correctness, maintainability, and clean design over speed.
- Fix root causes instead of masking symptoms.
- Inspect the repository before adding conventions.
- Preserve existing project style unless it is clearly broken.
- Avoid over-engineering simple flows.
- Report uncertainty honestly.

## Default Flutter Preferences

These are defaults only. Repo-specific patterns override them.

- Always follow the repository's existing state management pattern first.
- Do not migrate state management just to match personal preference.
- If the repository has no clear pattern, prefer:
  - local state for simple ephemeral UI state
  - Cubit for simple feature state
  - BLoC for complex event-driven flows, auditability, and strict state transitions
  - Riverpod when lower boilerplate, dependency management, and async provider composition are more valuable
- Prefer `bloc_test` and `mocktail` when the repo uses BLoC/Cubit.
- Keep widgets flexible, composable, reusable, and theme-aware.
- Avoid business logic inside widgets.
- Prefer small presentation widgets over large `build` methods.
- Avoid unnecessary Clean Architecture ceremony.

Additional Flutter default rules live in `/home/dev/.factory/rules/`:

- `architecture.md` — feature-first + Clean Architecture defaults
- `routing.md` — `go_router` named-route and route-scoped provider defaults
- `dependency-injection.md` — `get_it` + `injectable` defaults
- `localization.md` — ARB + `context.l10n` defaults
- `codegen.md` — `build_runner` workflow ordering
- `lint-defaults.md` — common analyzer rules to suggest

All of the above are defaults; repo-specific `AGENTS.md` and `.factory/*` still override them.

## Custom Skills

Use these global Factory skills when relevant:

- `brainstorming`: design exploration, requirements clarification, approach comparison before planning.
- `planning`: producing implementation plans for non-trivial tasks.
- `plan-execution`: executing approved plans, specs, checklists, or multi-step tasks with review checkpoints.
- `subagent-driven-development`: dispatching independent plan tasks to specialized droids in parallel.
- `bug-hunter`: bugs, regressions, async/state issues, root-cause investigation.
- `test-driven-development`: test-first implementation for features, bug fixes, and behavior changes.
- `flutter-widget`: Flutter UI, widgets, screens, and design-system components.
- `flutter-bloc`: BLoC/Cubit implementation, refactoring, and tests.
- `karpathy-guidelines`: think-first, surgical-edits posture for non-trivial coding.
- `code-review`: reviewing diffs, PRs, and implementation quality.
- `receiving-code-review`: applying, evaluating, or responding to review feedback.
- `verification`: evidence before claiming work is done, fixed, passing, or safe to merge.
- `git-workflow`: git state, staging, commits, merges, local excludes, and tracked-file decisions.
- `worktrees`: isolated branches/workspaces for parallel or risky work.
- `branch-completion`: merge, PR, keep-branch, discard, worktree cleanup, local-only decisions after implementation.
- `token-economy`: concise, high-signal, token-efficient output.

## Token Economy

Default to concise, high-signal communication.

- No filler.
- No repeated context.
- No unnecessary explanations.
- Prefer compact bullets, checklists, and command-first answers.
- Do not compress code, commands, paths, errors, package names, model names, env vars, or architecture decisions where nuance matters.

## frun Wrapper

Use `frun` when available for shell commands:

```bash
frun git status
frun git diff
frun flutter test
frun flutter analyze
frun rg "pattern"
```

`frun` uses RTK if installed and falls back to the raw command if RTK is unavailable. Never fail a task because RTK is unavailable.

## Validation Expectations

Before finishing implementation work, run the most relevant available commands:

- `flutter analyze`
- `flutter test`
- project-specific test scripts
- project-specific code generation checks

If validation cannot be run, explain why.

## Final Response Format for Coding Tasks

Return:

1. Changed
2. Validated
3. Risks/uncertainties
4. Next action, only if needed

## General Behavior

Do not add unrequested features or refactors.
Ask before making architectural decisions.
If unsure, ask — don't assume.
When asking, brainstorming or planning, suggest your opinion on the best option and why.
