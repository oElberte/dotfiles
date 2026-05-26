---
name: verification
description: Use before claiming work is done, fixed, passing, safe to merge, ready to commit, or when validating code/config/context changes
---

# Verification

Evidence before claims. No "done", "fixed", "passing", "ready", or "safe to merge" without fresh proof.

## Gate

Before saying work is done, fixed, passing, ready to merge, or safe:

1. Identify what proves the claim.
2. Run the relevant command or inspection fresh.
3. Read the output and exit code.
4. Report the actual result.
5. If verification cannot run, say why and name the command that should run.

If any step is skipped, do not make the claim. Report the actual state instead.

## Common proof

| Claim | Proof |
| --- | --- |
| Flutter code is valid | `fvm flutter analyze` or repo analyzer command |
| Flutter tests pass | `fvm flutter test` or focused test command |
| Generated files are current | repo codegen command |
| Context files were created | `git diff -- AGENTS.md .factory` and file tree inspection |
| No unrelated changes | `git status --porcelain` and diff review |
| Commit is safe | `git status`, `git diff --cached`, secret scan by inspection |
| Worktree can be cleaned | `git status --porcelain`, merge/branch state, user approval |

## Guardrails

- Do not claim success from assumptions.
- Do not trust previous runs after edits.
- Do not treat lint as proof tests pass.
- Do not treat tests as proof every requirement is met.
- Do not trust subagent success reports without inspecting the diff and relevant evidence.
- Do not commit, merge, push, or cleanup based only on confidence.
- Do not use words like "done", "fixed", "passing", "clean", "safe", or "ready" unless the evidence was just collected.
- If only context/config files changed, validate the diff and discovery path instead of running heavy app tests unless needed.

## If verification fails

1. State the failing command and failure.
2. Diagnose systematically.
3. Fix only failures caused by the current change.
4. Re-run the failing command.
5. If failure is pre-existing or unrelated, show evidence and ask before touching it.

## Final report

1. Validated commands/inspection
2. Result
3. Skipped checks with reason
4. Remaining risks
