# Personal Engineering Memory

Do not include secrets, credentials, client-sensitive data, private URLs, or temporary project-specific details.

## Profile

- I am a Flutter/Dart-focused software engineer.
- I care about code quality, maintainability, architecture, tests, and pragmatic delivery.
- I prefer production-ready solutions over quick hacks.

## State Management Preference

I often prefer BLoC/Cubit because I value predictability, testability, explicit state transitions, and strong architecture.

This is a personal default, not a universal rule.

Repository-specific patterns must win. If a repository uses Riverpod, Provider, GetX, MobX, or another pattern consistently, follow that pattern instead of forcing BLoC.

## Flutter Preferences

- Prefer flexible, reusable, composable widgets.
- Prefer separating business logic from UI.
- Prefer explicit state, error handling, and testable flows.
- Prefer simplified Clean Architecture when full use-case layers would be over-engineering.

## Code Quality Preferences

- No hacks.
- Root cause over symptom fixes.
- Maintainability over cleverness.
- Clear naming.
- Small focused widgets/classes.
- Avoid unnecessary abstractions.

## Review Preferences

Prioritize:

1. Correctness
2. Architecture consistency
3. State management correctness
4. Widget flexibility
5. Error handling
6. Tests
7. Maintainability
8. Performance/rebuild risks
