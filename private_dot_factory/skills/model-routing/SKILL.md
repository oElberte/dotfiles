---
name: model-routing
description: Route tasks between GPT 5.5 for logic/debug/security/backend work and Opus 4.8 for strict visual UI Page/Screen/component work.
---

# Model Routing

Use this skill when a task spans UI plus logic, debugging, backend, security, Flutter, Svelte, React, Vue, or other frontend work.

## Default model responsibilities

- Use the main Droid / GPT 5.5 for debugging, backend, security, architecture, state management, API contracts, data modeling, logic, validation, and final review.
- Use `gpt-debug-security` for read-only root-cause/security/backend/architecture investigation when an isolated GPT 5.5 scout is useful.
- Use `opus-ui-specialist` only for visual UI implementation/refinement in Page, Screen, view, component, layout, theme, responsive, animation, and style files.

## Conflict-safe workflow

Do not let multiple write-capable droids freely edit the same branch at the same time.

Recommended sequence:

1. GPT 5.5 inspects the repo and stabilizes logic, state, API, and method signatures first.
2. Delegate strict visual-only UI changes to `opus-ui-specialist`.
3. GPT 5.5 reviews the resulting diff for correctness, integration, security, and contract compatibility.
   If visual-only follow-up is needed, re-delegate it to `opus-ui-specialist`
   instead of editing visual UI files directly. GPT may only make tiny
   mechanical integration fixes when needed to preserve existing contracts.
4. Run the repository validators before completing.

Parallel work is safe only when it is read-only, or when workers are isolated in separate worktrees/branches and the main Droid merges/reconciles afterward.

## Strict UI-only constraints for Opus

When delegating to `opus-ui-specialist`, tell it:

- edit only Page/Screen/view/component/style/layout/theme files;
- use existing method signatures, props, callbacks, state values, routes, design tokens, and types exactly as found;
- do not edit backend, service, repository, API client, state-management business logic, model/entity/DTO, generated, migration, auth/security, or build config files;
- do not add new runtime computations, derived text, or user-visible copy for decoration; prefer empty `aria-hidden` elements, CSS, or pseudo-elements;
- stop and report missing callbacks/APIs/state instead of inventing them.

## Parent Droid responsibility

The main Droid owns orchestration, merge/review, validator discovery, test execution, and fixing integration issues. Never claim completion until the final diff has been reviewed and relevant validators pass.
For visual UI changes, the main Droid should orchestrate and review rather than implement the visual design itself; send visual corrections back to `opus-ui-specialist` unless the correction is purely mechanical.
