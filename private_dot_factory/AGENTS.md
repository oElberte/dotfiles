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

## General Behavior

Do not add unrequested features or refactors.
Ask before making architectural decisions.
If unsure, ask — don't assume.
When asking, brainstorming or planning, suggest your opinion on the best option and why.
