---
name: brainstorming
description: Use before creative work, features, components, architecture changes, behavior modifications, repo bootstraps, or any task where requirements, design, or trade-offs are unclear
---

# Brainstorming

Explore intent, requirements, and design before coding.

## When to use

Always before:

- New features or components
- Architecture or behavior changes
- Repo bootstraps and context generation
- Ambiguous requirements
- Tasks with multiple plausible approaches

Skip for one-file trivial edits or when the user gives an exact design.

## Process

1. **Inspect context**: current files, conventions, commands, git state.
2. **Understand**: ask one question at a time about purpose, constraints, success criteria.
3. **Propose approaches**: 2-3 options with trade-offs, recommend one.
4. **Present design**: architecture, components, data flow, error handling, testing.
5. **Incremental approval**: confirm each section before proceeding.

## Design principles

- Break the system into small units with clear responsibilities.
- Each unit answers: what does it do, how is it used, what does it depend on.
- Can someone understand the unit without reading its internals? Can internals change without breaking consumers?
- YAGNI — remove speculative features.

## In existing codebases

- Follow existing patterns.
- Fix structural problems only when they block the current goal.
- No unrelated refactors.

## Output

1. Goal
2. Constraints and assumptions
3. Approach options with trade-offs
4. Recommended design
5. Components and interfaces
6. Data flow
7. Error handling strategy
8. Testing strategy
9. Risks and open questions

After design approval, hand off to `planning`.
