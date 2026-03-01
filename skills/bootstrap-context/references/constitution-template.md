# Project Constitution

> This is the project's core context document — loaded every session. Keep it concise, accurate, and current. When in doubt, link to specs/ rather than inlining details.

## 1. Project Objectives

<!-- What does this project do? Who uses it? What problem does it solve? -->

- **Purpose**: {describe the project's core purpose}
- **Users**: {who uses this — internal team, external customers, API consumers}
- **Key outcomes**: {what success looks like}

## 2. Technology Stack

<!-- Core technologies, frameworks, and runtime versions -->

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | {e.g., TypeScript} | {e.g., 5.x} |
| Runtime | {e.g., Node.js / Bun} | {e.g., 22.x / 1.x} |
| Framework | {e.g., Next.js} | {e.g., 15.x} |
| Database | {e.g., PostgreSQL} | {e.g., 16.x} |
| Package Manager | {e.g., bun} | |
| Testing | {e.g., vitest} | |

## 3. Conventions & Standards

<!-- Non-obvious rules that an AI agent must follow -->

- **Naming**: {e.g., kebab-case files, PascalCase components, camelCase functions}
- **Imports**: {e.g., path aliases via @/, barrel exports discouraged}
- **Error handling**: {e.g., Result types preferred over thrown exceptions}
- **State management**: {e.g., server state in React Query, UI state in Zustand}
- **Code style**: {e.g., Prettier + ESLint, no semicolons, single quotes}

## 4. Build & Run Commands

<!-- Commands an agent needs to build, test, lint, and deploy -->

```bash
# Install dependencies
{package_manager} install

# Development
{package_manager} run dev

# Build
{package_manager} run build

# Test
{package_manager} test

# Lint
{package_manager} run lint

# Type check
{package_manager} run typecheck
```

## 5. Architectural Summary

<!-- High-level architecture in 3-5 sentences. Link to specs/ for details. -->

{Describe the major layers/components and how they interact. Keep this to a paragraph — subsystem details belong in specs/.}

**Key architectural decisions:**
- {e.g., Monorepo with shared packages}
- {e.g., API-first design, OpenAPI spec drives types}
- {e.g., Event-driven between services}

> For detailed subsystem documentation, see `specs/`.

## 6. Operational Checklists

### Before committing
- [ ] Tests pass (`{test_command}`)
- [ ] Linter clean (`{lint_command}`)
- [ ] No secrets in staged files
- [ ] Type check passes (`{typecheck_command}`)

### Before deploying
- [ ] All CI checks green
- [ ] Migration scripts reviewed (if applicable)
- [ ] Environment variables confirmed for target env

### When adding a new {component type}
- [ ] {Step 1}
- [ ] {Step 2}
- [ ] {Step 3}

## 7. Known Failure Modes

<!-- Common mistakes an AI agent makes in this codebase — link to failure-modes.md for the full table -->

> See `failure-modes.md` for the complete symptom → cause → fix table.

**Top 3 recurring issues:**
1. {e.g., "Forgetting to run migrations after schema change → type errors at runtime"}
2. {e.g., "Using relative imports instead of @ aliases → build breaks in monorepo"}
3. {e.g., "Editing generated files directly → changes overwritten on next codegen"}

## 8. Trigger Table Reference

<!-- Summary of routing intelligence — link to trigger-tables.md for the full table -->

> See `trigger-tables.md` for the complete routing table.

**Key routing rules:**
- Files matching `{pattern}` → use {agent/skill}
- Files matching `{pattern}` → use {agent/skill}
- Keywords `{terms}` → invoke {agent/skill}

## 9. Codification Protocol

<!-- Instructions for the AI agent to self-detect when knowledge should be captured -->

**During every session, watch for these signals:**
- You explained the same concept **twice** → write it down in the constitution or relevant spec
- You discovered a **failure mode** → add it to `failure-modes.md`
- You made an **architecture decision** → document in the relevant spec or constitution §5
- You found a **gotcha or non-obvious constraint** → add to §3 (Conventions) or §7 (Failure Modes)
- You established a **new convention** → add to §3

**When you detect a signal:**
1. Propose the specific addition (quote the section, show the diff)
2. Wait for human approval before writing
3. Keep additions concise — link to specs/ for details

## 10. Maintenance Schedule

<!-- When to review and update this constitution -->

- **Every 2 weeks**: Review §7 (Failure Modes) — remove resolved, add new
- **Monthly**: Review §2 (Tech Stack) and §4 (Build Commands) — versions drift
- **After major refactors**: Review §5 (Architecture) and §8 (Trigger Tables)
- **After onboarding new agent/skill**: Update §8 (Trigger Tables)

> Last reviewed: {date}
> Last bootstrap: {date}
