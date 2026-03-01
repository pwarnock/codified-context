# Subsystem Map

> Maps directories to logical subsystems with ownership, dependencies, and documentation links. Used for routing (trigger tables), staleness detection, and coverage analysis.

## Subsystem Overview

```
{project-root}/
├── src/
│   ├── {subsystem-1}/     → {Subsystem 1 Name}
│   ├── {subsystem-2}/     → {Subsystem 2 Name}
│   ├── {subsystem-3}/     → {Subsystem 3 Name}
│   └── shared/            → Shared utilities
├── tests/                 → Test infrastructure
├── docs/                  → Documentation
└── config/                → Configuration & infrastructure
```

## Detailed Subsystem Mapping

| Directory Pattern | Subsystem | Description | Spec Document | Dependencies |
|------------------|-----------|-------------|---------------|--------------|
| `src/{path}/**` | {Name} | {What this subsystem does} | `specs/{name}.md` | {Other subsystems it depends on} |

## Subsystem Boundaries

### {Subsystem 1 Name}
- **Root**: `src/{path}/`
- **Purpose**: {What it does}
- **Key files**: {Entry points, main modules}
- **Public API**: {What other subsystems consume from this one}
- **Dependencies**: {What this subsystem imports from others}
- **Spec**: `specs/{name}.md`

### {Subsystem 2 Name}
- **Root**: `src/{path}/`
- **Purpose**: {What it does}
- **Key files**: {Entry points, main modules}
- **Public API**: {What other subsystems consume from this one}
- **Dependencies**: {What this subsystem imports from others}
- **Spec**: `specs/{name}.md`

## Cross-Cutting Concerns

| Concern | Affected Subsystems | Implementation Pattern |
|---------|--------------------|-----------------------|
| {e.g., Logging} | {All} | {e.g., Structured JSON via shared logger} |
| {e.g., Auth} | {API, Admin} | {e.g., Middleware chain, JWT validation} |
| {e.g., Error handling} | {All} | {e.g., Result types, centralized error boundary} |

## Hot Areas (High Change Frequency)

<!-- Auto-populated by analyze-repo.sh, updated during staleness audits -->

| Directory | Commits (30d) | Risk Level | Notes |
|-----------|--------------|------------|-------|
| {path} | {count} | {High/Medium/Low} | {Why this area changes frequently} |

## Adding New Subsystems

When a new logical subsystem emerges:
1. Add directory mapping to the table above
2. Create a boundary section with purpose, key files, API, dependencies
3. Create `specs/{name}.md` with detailed documentation
4. Add routing rules to `trigger-tables.md`
5. Update constitution §5 (Architectural Summary) if the subsystem is significant
