# Routing Defaults

Apply only when the repo already uses `go_router`. Do not migrate routing solutions.

- Centralize route configuration in a single router file (e.g., `lib/app/router.dart` or `lib/core/router/app_router.dart`).
- Define route paths and names as constants on a router class; reference them via `*Name` constants.
- Prefer named navigation:
  - `context.pushNamed(...)` to navigate forward with back stack
  - `context.goNamed(...)` to replace the current location
  - `context.pop()` to return
- Avoid raw `context.go('/path')` string navigation inside widgets.
- Provide route-scoped BLoCs/Cubits via `BlocProvider` / `MultiBlocProvider` inside the route `builder`, not inside screen widgets. This gives automatic disposal on pop.
- Use `StatefulShellRoute.indexedStack` for persistent bottom-nav tabs that must keep state.
- Keep deep-link handling and redirects centralized in the router, not in widgets.
