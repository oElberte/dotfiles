# Dependency Injection Defaults

Apply only when the repo already uses `get_it` (often with `injectable`). Do not migrate DI solutions.

- Register globals and stateless services as **lazy singletons**.
- Register screen/feature scoped BLoCs/Cubits as **factories** so they are recreated per navigation.
- Register stateful long-lived caches and stream owners as **singletons** only when their lifetime spans the whole app.
- Group registrations by feature/module (e.g., `auth_module.dart`, `database_module.dart`) instead of one large registration file.
- Keep DI bootstrap in a single `configureDependencies()` (or `setupServiceLocator()`) called once from `main` before `runApp`.
- After adding or changing `@injectable` annotations, regenerate with `build_runner` before running analyzer/tests.
- Do not call `getIt`/`sl` from deep within widget trees; resolve at the route builder or feature entry point and inject explicitly.
- Provide repository **interfaces** (abstract classes) and register their implementations against the interface type to keep tests easy to mock.
