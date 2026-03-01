# Trigger Tables

> Routing intelligence: maps file patterns and keywords to the right agent, skill, or context document. The AI agent consults this table to decide which specialist to invoke.

## File Pattern Routing

| File Pattern | Keywords | Agent/Skill | Rationale |
|-------------|----------|-------------|-----------|
| `src/api/**` | endpoint, route, handler | {api-specialist} | API layer has specific conventions for error handling, auth middleware |
| `src/db/**`, `migrations/**` | schema, migration, query | {db-specialist} | Database changes require migration awareness and query optimization |
| `src/components/**` | component, UI, render | {frontend-specialist} | Component conventions differ from backend patterns |
| `tests/**` | test, spec, mock, fixture | {test-specialist} | Test patterns, fixtures, and mocking strategies are domain-specific |
| `*.config.*`, `.env*` | config, environment, setup | {infra-specialist} | Configuration changes can have cascading effects |
| `docs/**`, `*.md` | documentation, readme | {docs-specialist} | Documentation has style and structure conventions |

## Keyword Routing

| Keyword/Phrase | Context to Load | Action |
|---------------|-----------------|--------|
| "deploy", "release" | `specs/deployment.md` | Load deployment procedures and checklists |
| "auth", "permission", "role" | `specs/auth.md` | Load authentication/authorization architecture |
| "migration", "schema change" | `specs/database.md` | Load database conventions and migration procedures |
| "performance", "slow", "optimize" | `specs/performance.md` | Load performance baselines and optimization patterns |
| "error", "exception", "crash" | `failure-modes.md` | Load known failure modes for rapid diagnosis |

## Subsystem Routing

| Subsystem | Entry Point | Spec Document | Owner Agent |
|-----------|------------|---------------|-------------|
| {subsystem-name} | `src/{path}/` | `specs/{subsystem}.md` | {agent-name} |

## How to Use This Table

1. **On file open/edit**: Match the file path against "File Pattern Routing" → invoke the matched agent/skill
2. **On keyword detection**: Match conversation keywords against "Keyword Routing" → load the specified context
3. **On subsystem entry**: When working in a subsystem directory → load the matching spec document

## Adding New Routes

When you discover that a specific file pattern or keyword consistently needs specialized handling:
1. Add a row to the appropriate table above
2. Document the rationale (why this routing improves outcomes)
3. If a new spec document is needed, create it in `specs/`
4. Update the constitution §8 (Trigger Table Reference) summary
