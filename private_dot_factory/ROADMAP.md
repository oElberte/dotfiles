# Factory Droid Setup Roadmap

## Current state

- **16 custom skills** in `~/.factory/skills/`
- **2 slash commands**: `/init-flutter-repo`, `/populate-global-from-repos`
- **7 custom droids**: `bug-hunter`, `flutter-reviewer`, `plan-reviewer`, `coder`, `final-reviewer`, `mid-dev`, `worker`
- **6 global rules** in `~/.factory/rules/`
- **2 prompts** in `~/.factory/prompts/`
- **`frun` wrapper** in `~/.factory/bin/` (RTK fallback)
- **`memories.md`** with personal Flutter/BLoC preferences

External Superpowers and Caveman skills are backed up, not active.

## How Droid discovers skills and commands

Droid auto-discovers:

- **Skills**: from `~/.factory/skills/*/SKILL.md` — activated by name or when the description matches the task
- **Commands**: from `~/.factory/commands/*.md` — invoked via `/command-name`
- **Droids**: from `~/.factory/droids/*.md` — used via `Task` tool or by name
- **Rules**: from `~/.factory/rules/*.md` — loaded as context
- **AGENTS.md**: loaded as system prompt in every session

No manual activation needed. Droid reads the skill descriptions and activates them when relevant.

## Recommended daily flow

### New feature or refactor

1. **`brainstorming`** — explore requirements and design
2. **`planning`** — write an implementation plan
3. **`worktrees`** — create isolated workspace
4. **`test-driven-development`** — write failing test first
5. **`plan-execution`** — implement task by task
6. **`verification`** — confirm all checks pass
7. **`branch-completion`** — choose merge/PR/cleanup

### Bug

1. **`bug-hunter`** — root-cause investigation
2. **`test-driven-development`** — write reproduction test
3. Fix → verify → `branch-completion`

### Review

1. **`code-review`** or `flutter-reviewer` droid
2. **`receiving-code-review`** — apply feedback

### Bootstrap a repo

1. `/init-flutter-repo` — generates `.factory/` and `AGENTS.md` per repo
2. Answer the privacy gate at the end: committed or local-only

### Populate global defaults

1. `/populate-global-from-repos` — inspects all repos from `flutter-repos.txt`

## Setup remaining tasks

After restarting Droid, do these in order:

1. **Create `~/.factory/flutter-repos.txt`** with one absolute path per line:
   ```
   /home/dev/Development/Personal/ConstruApp
   /home/dev/Development/Personal/OtherFlutterApp
   ```
   Use absolute paths. One repo per line.

2. **Populate global defaults**:
   ```
   /populate-global-from-repos
   ```
   Start in planning mode first. Review proposed changes before writing.

3. **Bootstrap another Flutter repo**:
   ```
   cd /path/to/repo
   /init-flutter-repo
   ```

4. **Fix GPT provider config** (last step):
   In `~/.factory/settings.json`, change GPT-5.5 and related models from
   `"provider": "generic-chat-completion-api"` to `"provider": "openai"`.
   Only do this when you're ready to restart the model.

## Backup location

External skills backup: `~/.factory/backups/external-skills-2026-05-18/`

Contains: `caveman`, `caveman-commit`, `caveman-compress`, `caveman-help`,
`caveman-review`, `compress`, `superpowers` (symlink), and `README.md`
with rollback instructions.

## File map

```
~/.factory/
├── AGENTS.md              ← loaded every session
├── memories.md            ← personal engineering memory
├── flutter-repos.txt      ← create this (absolute paths, one per line)
├── bin/frun               ← RTK fallback wrapper
├── rules/                 ← global coding rules
│   ├── bloc.md
│   ├── flutter.md
│   ├── quality.md
│   ├── testing.md
│   ├── token-economy.md
│   └── widget-composition.md
├── skills/                ← auto-discovered by Droid
│   ├── brainstorming/
│   ├── branch-completion/
│   ├── bug-hunter/
│   ├── code-review/
│   ├── flutter-bloc/
│   ├── flutter-widget/
│   ├── git-workflow/
│   ├── karpathy-guidelines/
│   ├── plan-execution/
│   ├── planning/
│   ├── receiving-code-review/
│   ├── subagent-driven-development/
│   ├── test-driven-development/
│   ├── token-economy/
│   ├── verification/
│   └── worktrees/
├── commands/              ← slash commands
│   ├── init-flutter-repo.md
│   └── populate-global-from-repos.md
├── droids/                ← custom subagents
│   ├── bug-hunter.md
│   ├── flutter-reviewer.md
│   ├── coder.md
│   ├── final-reviewer.md
│   ├── mid-dev.md
│   ├── plan-reviewer.md
│   └── worker.md
├── prompts/               ← reusable prompts
│   ├── bootstrap-repo-factory.md
│   └── populate-global-from-repos.md
└── backups/
    └── external-skills-2026-05-18/
```

## Skill summary

| Skill | Trigger |
|---|---|
| `brainstorming` | Before creative work, unclear requirements |
| `planning` | Multi-file implementation, refactors |
| `plan-execution` | Executing approved plans |
| `subagent-driven-development` | Parallel independent tasks |
| `bug-hunter` | Bugs, test failures, unexpected behavior |
| `test-driven-development` | Features, bug fixes, behavior changes |
| `flutter-widget` | Flutter UI, widgets, design-system |
| `flutter-bloc` | BLoC/Cubit implementation, review, tests |
| `karpathy-guidelines` | Non-trivial coding, refactors, risky changes |
| `code-review` | Reviewing diffs, PRs, implementation quality |
| `receiving-code-review` | Applying review feedback |
| `verification` | Before claiming done/fixed/passing |
| `git-workflow` | Git state, staging, commits, local-only files |
| `worktrees` | Isolated workspaces, parallel work |
| `branch-completion` | Merge, PR, keep, discard after implementation |
| `token-economy` | Concise output, low token usage |
