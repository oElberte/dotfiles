---
name: address-pr-and-learn
description: Address a pull request's reviewer comments and failing CI checks, then distill generalizable conventions from the feedback into the .factory knowledge base (MEMORIES.md, AGENTS.md, rules). Use when given a PR number or URL and the goal is to both fix the feedback and have the agent learn from it.
---

# Address PR and Learn

Two phases on a single PR:

- **Phase A — Address:** fix the code for every reviewer finding and failing CI check.
- **Phase B — Learn:** turn *generalizable* feedback into durable rules in the right `.factory` location.

This skill is language- and framework-agnostic. Substitute the project's real build/lint/test/format commands where examples appear.

## Two hard gates (never cross without explicit user confirmation)

1. **Push & reviewer replies.** Code edits are automatic. Pushing to remote, posting reviewer replies, and posting PR comments are **not**. Present the draft text and ask; act only on confirmation.
2. **Memory writes.** Extracting candidate learnings is automatic. Writing to any `MEMORIES.md`, `AGENTS.md`, rule, or skill file is **not**. Present proposed entries and write only what the user approves.

Also: respect untracked files (never delete/overwrite them); never write secrets.

## Inputs

- **PR reference** (required): bare number → current repo; full URL → extract `owner/repo/number`.

---

## Phase 0 — Resolve & Fetch

1. **Preflight:**
   ```bash
   gh auth status            # confirm gh is authenticated
   git rev-parse --show-toplevel   # confirm we're inside a git repo
   ```
   If either fails, stop and report what the user needs to fix.

2. **Resolve the PR.** Set `N` (number) and, for URLs, `owner/repo`. For bare numbers, gh uses the current repo by default. Use `-R owner/repo` on every `gh` call when a URL was given.

3. **Fetch everything:**
   ```bash
   # Metadata, body, branches, state, CI rollup
   gh pr view N --json number,title,body,headRefName,baseRefName,state,url,statusCheckRollup

   # The diff
   gh pr diff N

   # General (issue-level) comments
   gh api repos/<owner>/<repo>/issues/N/comments

   # Inline review comments (file/line threads); note in_reply_to_id to skip answered ones
   gh api repos/<owner>/<repo>/pulls/N/comments

   # Review summaries / states (APPROVED, CHANGES_REQUESTED, etc.)
   gh api repos/<owner>/<repo>/pulls/N/reviews

   # CI checks
   gh pr checks N
   ```

4. **Read the diff and the changed files in depth.** Understand intent and scope before changing anything.

5. **Checkout the head branch:**
   ```bash
   git fetch origin <headRefName> <baseRefName>
   git checkout <headRefName>
   ```

Build a working list of findings. For each: source (reviewer comment / CI check), location, what's being asked, and whether it already has a reply (`in_reply_to_id`) — skip already-answered threads.

---

## Phase A — Address (code auto; push/reply gated)

### A1. Fix reviewer comments
For each unresolved finding:
1. Understand what's being asked (or why it may not apply).
2. Make the code change.
3. Add/adjust tests if requested.
4. Note a one-line draft reply describing what you did.

### A2. Fix failing CI checks
For each failing check from `gh pr checks` / `statusCheckRollup`:
1. Pull the failing log:
   ```bash
   gh run view <run-id> --log-failed
   ```
2. Diagnose and fix. **Distinguish pre-existing base-branch failures** (in files the PR didn't touch) from PR-introduced ones — verify against the base branch before spending effort on the former.

### A3. Verify locally
Discover the project's commands from the repo root (`Makefile`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `build.gradle`, `justfile`, `Taskfile.yml`, CI workflow, etc.). Prefer scoped/filtered runs for the affected areas:
- JS/TS: `npm test -- --filter=<pkg>`, `pnpm -r --filter <pkg> test`, `nx test <project>`
- Python: `pytest <path>`, `tox -e <env>`
- Rust: `cargo test -p <crate>`, `cargo clippy -p <crate>`
- Go: `go test ./<pkg>/...`, `golangci-lint run ./<pkg>/...`
- JVM: `./gradlew :<module>:test`, `./mvnw -pl <module> test`

### A4. Stop at the gate
Make a local commit if helpful, but **do not push**. Present to the user:
- Per-finding summary: finding → what was changed (files/lines).
- **Draft reviewer replies** as copy-pasteable text, one per addressed thread.
- An offer: *"Push `<headRefName>` and post these replies for you? (y/n)"*

Only if confirmed:
```bash
git push origin <headRefName> --force-with-lease

# Reply to an inline thread
gh api repos/<owner>/<repo>/pulls/N/comments/<COMMENT_ID>/replies -X POST -f body="<reply>"

# Or a general summary comment
gh pr comment N --body "<summary>"
```
If a secret-scanning bot blocks the push, tell the user — the agent cannot override it.

---

## Phase B — Learn (extract auto; write gated)

### B1. Classify every finding
A finding becomes a **memory candidate** only if it is:
- **Generalizable** — would apply to future PRs, not just this code path.
- **Convention / preference / architecture** — style, naming, patterns, testing norms, library choices, structural rules, or a reviewer's stated preference.

**Discard** one-off logic bugs, typos, and context-specific fixes. If in doubt, lean toward discarding — a noisy memory file is worse than a missing entry.

### B2. Route each candidate (smart routing)
- **Codebase-specific convention** → target repo `.factory/MEMORIES.md`. Create the file/dir if absent. If it's a hard, always-on rule, additionally propose promoting it into the repo's `.factory/AGENTS.md` (keep AGENTS.md lean).
- **Cross-cutting personal preference** (applies across all your projects) → global `~/.factory/MEMORIES.md`.
- **Multi-step workflow** (rare) → propose a new/updated skill or command rather than a memory line.

### B3. Dedup on write
Before proposing an entry, read the destination `MEMORIES.md`:
- If a near-duplicate exists → skip or refine the existing line.
- If it **contradicts** an existing rule → propose replacing the old line (show both), and note the newer source wins.
- Otherwise → propose a new entry under the right category.

### B4. Propose, then write only on approval
Present a table of proposed changes:

| # | Target file | Category | Rule | Why | Source |
|---|-------------|----------|------|-----|--------|

Ask the user to approve/edit/reject per row. Write only approved rows. Use this entry format:

```
- <rule>. _Why:_ <rationale>. [PR #<n> · @<reviewer> · <YYYY-MM-DD>](<comment-url>)
```

Categories in `MEMORIES.md`: Code Style, Testing, Architecture, Naming, Git, Reviewer Preferences, Other. Add the entry under the matching heading (create the heading if missing).

---

## Final Report

```
## /review-learn: PR #<n> — <title>

### Addressed
- <finding> → <fix> (<files>)
- CI <check> → <fix>

### Pending your action
- [ ] Push <branch>  (or: pushed ✅)
- [ ] Post N reviewer replies  (drafts above / or: posted ✅)

### Learned (written after your approval)
- <target file> · <category> · <rule>

### Discarded as one-off (not memorized)
- <finding>
```

## Verification checklist
- [ ] All reviewer comments + failing CI addressed in code
- [ ] Affected-area lint/typecheck/tests pass locally
- [ ] Push & replies done only with explicit confirmation
- [ ] Memory candidates classified; one-offs discarded
- [ ] Proposed entries deduped against existing memory
- [ ] Files written only after user approval, with source attribution
