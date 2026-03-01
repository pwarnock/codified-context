# Context Drift Patterns

> Common patterns of context staleness and how to remediate them. Used by the audit-staleness skill to classify and prioritize drift.

## Drift Categories

### 1. Path Drift
**Signal**: File paths referenced in context docs no longer exist
**Severity**: High — broken references cause agent confusion
**Common causes**: Refactoring, directory reorganization, file deletion
**Remediation**: Update or remove the reference, check if the concept moved elsewhere

### 2. API Drift
**Signal**: Function signatures, class interfaces, or API endpoints changed
**Severity**: High — agents generate incorrect code
**Common causes**: Interface evolution, breaking changes, version upgrades
**Remediation**: Update function signatures in specs, check for cascading references

### 3. Convention Drift
**Signal**: Codebase conventions evolved but constitution §3 still reflects old patterns
**Severity**: Medium — agents follow outdated patterns
**Common causes**: Team decisions, linter config changes, framework upgrades
**Remediation**: Audit recent PRs for convention changes, update §3

### 4. Dependency Drift
**Signal**: Technology stack versions in constitution §2 are outdated
**Severity**: Low-Medium — agents may suggest deprecated APIs
**Common causes**: Regular dependency updates
**Remediation**: Cross-reference package.json/go.mod/etc. with §2

### 5. Command Drift
**Signal**: Build/test/lint commands in constitution §4 fail or are renamed
**Severity**: High — agents can't build or test
**Common causes**: Script reorganization, tool migration
**Remediation**: Verify all commands, update §4

### 6. Subsystem Drift
**Signal**: New directories or subsystems not reflected in subsystem-map.md
**Severity**: Medium — new subsystems lack routing and documentation
**Common causes**: Feature additions, service extraction
**Remediation**: Add new subsystems to map, create routing rules, write specs

### 7. Coverage Decay
**Signal**: Subsystem specs haven't been updated as code evolves
**Severity**: Medium — specs become misleading over time
**Common causes**: Velocity pressure, no update triggers
**Remediation**: Schedule spec reviews with major feature work

## Staleness Heuristics

| Metric | Green | Yellow | Red |
|--------|-------|--------|-----|
| Document age | < 14 days | 14-30 days | > 30 days |
| Path validity | > 95% | 80-95% | < 80% |
| Git coverage | > 80% | 50-80% | < 50% |
| Command validity | 100% | 80-100% | < 80% |

## Priority Matrix

| Severity | Impact | Action |
|----------|--------|--------|
| High + Recent | Blocking | Fix immediately |
| High + Old | Misleading | Fix this session |
| Medium + Recent | Degrading | Fix this week |
| Medium + Old | Background | Fix during maintenance |
| Low | Cosmetic | Fix when convenient |
