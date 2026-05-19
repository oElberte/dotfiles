# Widget Composition Rules

- Inspect nearby widgets and design-system components before creating new UI.
- Prefer composition over flags-heavy widgets.
- Keep widget APIs flexible but not speculative.
- Use existing theme tokens, spacing, typography, colors, and localization patterns.
- Avoid business logic, networking, persistence, and complex transformations in widgets.
- Extract presentation widgets when `build` grows large or mixes responsibilities.
- Minimize rebuild scope for expensive or frequently changing UI.
- Preserve accessibility, responsive layout, and text scaling behavior.
