---
name: flutter-widget
description: Use when creating, refactoring, or reviewing Flutter widgets, screens, UI components, design-system components, or layout behavior
---

# Flutter Widget

Build UI by following the repository's existing design system and composition style.

## Checklist

- Inspect nearby widgets before adding new patterns.
- Use existing theme tokens, spacing, typography, localization, and responsive helpers.
- Keep widgets small, composable, and theme-aware.
- Avoid business logic, networking, persistence, and complex transformations in UI.
- Avoid unnecessary `StatefulWidget`; use it only when local mutable UI state is needed.
- Prefer composition over broad flag-heavy APIs.
- Limit rebuild scope with focused builders/selectors when state changes frequently.
- Preserve accessibility, text scaling, loading, empty, and error states.

## Output

1. Existing UI pattern found
2. Widget/component design
3. State and data inputs
4. Rebuild/performance considerations
5. Validation plan
