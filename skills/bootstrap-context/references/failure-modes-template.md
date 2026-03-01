# Known Failure Modes

> Symptom → Cause → Fix mappings. When the AI agent encounters an error or unexpected behavior, consult this table first. This is the project's institutional memory for debugging.

## Critical Failures

| # | Symptom | Cause | Fix | Prevention |
|---|---------|-------|-----|------------|
| 1 | {error message or behavior} | {root cause} | {specific fix steps} | {how to avoid in future} |

## Build & Compile Failures

| # | Symptom | Cause | Fix | Prevention |
|---|---------|-------|-----|------------|
| 1 | {e.g., "Type error: Property X does not exist on type Y"} | {e.g., "Generated types are stale after schema change"} | {e.g., "Run `bun run codegen` to regenerate types"} | {e.g., "Always run codegen after schema changes"} |

## Runtime Failures

| # | Symptom | Cause | Fix | Prevention |
|---|---------|-------|-----|------------|
| 1 | {e.g., "Connection refused on port 5432"} | {e.g., "Database container not running"} | {e.g., "Run `docker compose up -d db`"} | {e.g., "Add to dev startup checklist"} |

## Test Failures

| # | Symptom | Cause | Fix | Prevention |
|---|---------|-------|-----|------------|
| 1 | {e.g., "Snapshot mismatch in ComponentX"} | {e.g., "Intentional UI change not reflected in snapshot"} | {e.g., "Run `bun test -- -u` to update snapshots"} | {e.g., "Update snapshots as part of UI change workflow"} |

## AI Agent-Specific Failures

| # | Symptom | Cause | Fix | Prevention |
|---|---------|-------|-----|------------|
| 1 | {e.g., "Agent edits generated file directly"} | {e.g., "No awareness of codegen pipeline"} | {e.g., "Edit source schema, then run codegen"} | {e.g., "Document generated files in constitution §3"} |

## Adding New Failure Modes

When you encounter and resolve a new failure:
1. Identify the **symptom** (what you observed — error message, unexpected behavior)
2. Determine the **root cause** (why it happened)
3. Document the **fix** (specific steps, not vague guidance)
4. Add **prevention** (what would have avoided this)
5. Place in the appropriate category above
6. If it's a top-3 recurring issue, update the constitution §7 summary

## Failure Mode Lifecycle

- **Add**: When a new failure is encountered and resolved
- **Update**: When a better fix or prevention strategy is found
- **Archive**: When the root cause is permanently fixed (move to bottom "Archived" section)
- **Review**: Every 2 weeks per the constitution maintenance schedule

---

## Archived Failures

<!-- Move resolved failure modes here instead of deleting them — they serve as historical context -->

| # | Symptom | Cause | Resolution Date | How Permanently Fixed |
|---|---------|-------|-----------------|-----------------------|
