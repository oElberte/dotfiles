<!-- context7 -->
Use Context7 MCP to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service -- even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer -- your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Always start with `resolve-library-id` using the library name and the user's question, unless the user provides an exact library ID in `/org/project` format
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question). Use version-specific IDs when the user mentions a version
3. `query-docs` with the selected library ID and the user's full question (not single words)
4. Answer using the fetched docs
<!-- context7 -->


<claude-mem-context>
# Memory Context

# [dev] recent context, 2026-04-19 2:02pm GMT-3

No previous sessions found.
</claude-mem-context>

## Git

Never sign commits as an AI or as anyone. Nothing of 'Co-Authored By' or 'Signed-Off-By' in commit messages.
Never use the word "Claude" in commit messages.
Use conventional commits standard.
Commit messages must be in English.

## Code Style

Prefer concise, direct responses — no excessive explanations unless asked.
When suggesting fixes, show only the relevant changed code, not the entire file.
Never add comments explaining what the code does unless explicitly asked.

## Flutter

If the project contains an `.fvmrc` file or a `.fvm/` directory, always use `fvm flutter` and `fvm dart` instead of calling `flutter` or `dart` directly in any shell command.

## General Behavior

Do not add unrequested features or refactors.
Ask before making architectural decisions.
If unsure, ask — don't assume.
