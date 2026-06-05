# Global Rules

## RTK (Rust Token Killer) — Command Proxy

**Always prefix shell commands with `frun` or `rtk`** — this proxies output through RTK's token-optimizing filter, reducing context pollution by 60-90%.

`frun` is the preferred wrapper in this config. It calls `rtk` when available and falls back to the raw command only if RTK is unavailable. Seeing `frun ...` in Droid transcripts counts as RTK usage.

This applies to ALL commands run via Execute, including in chains:

```bash
frun git add . && frun git commit -m "msg" && frun git push
frun npm install && frun npm run build
frun bash -c 'mkdir -p "$HOME/tmp" && chmod 700 "$HOME/tmp"'
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

If `rtk` is not found on the system, `frun` falls back to raw command execution.

## Context & Tools

Always use Context7 when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

## Git

Never sign commits as an AI or as anyone. Nothing of 'Co-Authored By' or 'Signed-Off-By' in commit messages.
Never use the word "Claude" in commit messages.
Use conventional commits standard.
Commit messages must be in English.

## Worktrees

When using git worktrees, always create them inside the repository root under `.worktrees/`.

- Required path shape: `<repo-root>/.worktrees/<short-name>`.
- Never create sibling worktrees next to the repo.
- Never create worktrees in `/tmp`, `$HOME`, a parent workspace, or any external directory.
- Before creating a worktree, ensure `.worktrees/` is ignored. If it is not ignored, add `.worktrees/` to `<repo-root>/.git/info/exclude`.
- If `<repo-root>/.worktrees/` cannot be used safely, stop and ask before using any other location or continuing in-place.

## Code Style

Prefer concise, direct responses — no excessive explanations unless asked.
When suggesting fixes, show only the relevant changed code, not the entire file.
Never add comments explaining what the code does unless explicitly asked.

## Adaptive GPT 5.5 quality pipeline

Default posture: keep GPT 5.5 as the main decision-maker and use GPT 5.5
`xhigh` for GPT-based chat, scouting, implementation, and review. Qwen/Gemini
remain independent reviewers for hard or risky work.

### Effort policy

- Main/coder/default GPT effort: GPT 5.5 `xhigh`.
- Expensive gates: GPT 5.5 `xhigh` for plan adjudication, final adjudication,
  hard debugging decisions, and repeated validation failures.
- Do not use `medium` for code-writing when quality matters. Use it only for
  read-only scouting/summarization if explicitly useful.
- Use Qwen and Gemini as independent reviewers only for riskier/harder work,
  not for every routine task.

### Automatic mode selection

The parent agent decides the lightest safe mode unless the user explicitly asks
for `fast-quality`, `full-jury`, `xhigh-coder`, `single agent`, or `skip the
pipeline`.

1. **Direct mode** — parent may implement directly:
   - One-file, <20-line trivial edits, exact mechanical changes, typos, small
     config tweaks, or pure read/search/report tasks.
   - Still run the relevant validators before claiming completion.

2. **Standard GPT mode** — default for most approved specs/plans:
   - Contained bug fixes/features/refactors with low/medium risk.
   - Usually 2–5 files, no auth/security/data-loss/schema/public-API risk, and
     clear validation commands.
   - Pipeline:
     1. `Task(subagent_type="plan-reviewer-gpt", ...)`
     2. `Task(subagent_type="plan-reviewer", ...)` with `mode=standard-gpt-only`
        and only the GPT reviewer report expected.
     3. `Task(subagent_type="coder", ...)` using GPT 5.5 `xhigh`.
     4. `Task(subagent_type="final-reviewer-gpt", ...)`
     5. `Task(subagent_type="final-reviewer", ...)` with
        `mode=standard-gpt-only` and only the GPT reviewer report expected.

3. **Full jury mode** — use for hard/risky work:
   - Architecture changes, migrations, storage/schema changes, auth/security,
     payments, permissions, concurrency/async correctness, routing/state
     boundaries, public APIs, broad refactors, generated/codegen-heavy work,
     unclear requirements, or changes likely to touch >5 files / >300 LOC.
   - Also use when validators fail for non-obvious reasons, the user asks for
     maximum quality, or confidence is below high.
   - Pipeline:
     1. Run in parallel:
        - `Task(subagent_type="plan-reviewer-gpt", ...)`
        - `Task(subagent_type="plan-reviewer-qwen", ...)`
        - `Task(subagent_type="plan-reviewer-gemini", ...)`
     2. `Task(subagent_type="plan-reviewer", ...)` with all reviewer reports.
     3. Use `Task(subagent_type="coder", ...)` by default, or
        `Task(subagent_type="coder-xhigh", ...)` for core algorithms,
        security-sensitive implementation, very complex refactors, or when the
        standard coder already failed once.
     4. Run in parallel:
        - `Task(subagent_type="final-reviewer-gpt", ...)`
        - `Task(subagent_type="final-reviewer-qwen", ...)`
        - `Task(subagent_type="final-reviewer-gemini", ...)`
     5. `Task(subagent_type="final-reviewer", ...)` with all reviewer reports.

### GPT-only scout swarm

Use scouts before planning or implementation when the code area is unfamiliar,
the blast radius is unclear, or the task can be cleanly split across
subsystems. Scouts are read-only GPT 5.5 `xhigh`; synthesis is GPT 5.5 `xhigh`.

- **0 scouts**: trivial/direct tasks.
- **1 scout**: small task in an unfamiliar area.
- **2–3 scouts**: normal multi-file work or unclear tests/wiring.
- **4–6 scouts**: hard/risky work with several independent concerns.
- **8 scouts**: broad migration/refactor across many modules.
- **10 scouts max**: exceptional repo-wide or high-risk work that is naturally
  partitionable, such as auth/security migrations, storage/schema migrations,
  platform-wide routing/state rewrites, or changes likely to affect >50 files.

Do not exceed 10 scouts without explicit user approval. More scouts only help
when they have non-overlapping scopes; otherwise use fewer scouts and a better
scope split.

Suggested 10-scout split for exceptional work:

1. Entrypoints and integration map.
2. Data model, persistence, migrations, and rollback risk.
3. Public API, contracts, backward compatibility, and callers.
4. State management, concurrency, async flows, and lifecycle edges.
5. UI/routing/presentation wiring.
6. Test coverage, fixtures, mocks, and validation commands.
7. Security, permissions, privacy, and secret handling.
8. Performance, resource usage, caching, and scalability.
9. Build, codegen, tooling, generated files, and CI.
10. Rollout sequencing, feature flags, compatibility windows, and cleanup risk.

Scout workflow:

1. Launch `Task(subagent_type="gpt-scout", ...)` calls in parallel, each with a
   narrow, non-overlapping scope.
2. For 3+ scout reports, run `Task(subagent_type="gpt-scout-synthesizer", ...)`
   before plan review or coding.
3. Feed accepted scout findings into the plan, plan-reviewer, or coder prompt.
4. If scouts disagree, prefer concrete file/line evidence and let the xhigh
   synthesizer/adjudicator decide.

When unsure between two modes, choose the safer higher-quality mode, but do not
default to full jury for routine contained tasks.

The parent session orchestrates during Standard GPT mode and Full jury mode; it
does not edit code itself while a pipeline is active.

### Operating rules

- Goal check before declaring done: re-read the original goal from the
  brainstorm and spec. Explicitly state whether anything from the
  brainstorm that didn't make it into the spec/plan was honored, missed,
  or worth surfacing. Wait for user confirmation before claiming complete.
- Review loop bounds: if the final-reviewer adjudicator returns
  REQUEST_CHANGES, dispatch only its accepted findings to coder and re-run the
  final-review jury. After 2 iterations without convergence, or if the same
  accepted finding survives 2 coder passes, STOP and escalate to the user with
  a summary. Never loop indefinitely.

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

## Plan, Spec, and Roadmap Hygiene

- Use repo-owned `docs/` folders as the canonical home for project planning artifacts:
  - active plans: `docs/plans/`
  - active specs: `docs/specs/`
  - roadmaps: `docs/roadmap/`
- Use project `.factory/` only for Factory/Droid configuration, project rules/skills/droids, or local scratch drafts — not canonical repo plans/specs/roadmaps.
- When a plan or spec is completed, merged, superseded, or no longer active, move it to `docs/plans/old/` or `docs/specs/old/` instead of leaving it in the active folder.
- Do not permanently delete archived plans/specs unless the user explicitly asks for permanent deletion.

## Screenshots and Visual Test Artifacts

- Save screenshots captured for viewing, testing, or validating apps (including Playwright/browser screenshots) under the repository's `docs/screenshots/` folder.
- Treat `docs/screenshots/` as local/temporary by default and usually ignore it via the repository's `.git/info/exclude`, not `.gitignore`.
- Before creating or relying on screenshots, check whether `docs/screenshots/` is already locally excluded; if it is not, confirm with the user before adding the local exclude or keeping screenshot artifacts.
- Do not commit screenshots unless the user explicitly asks for them to be tracked.

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
