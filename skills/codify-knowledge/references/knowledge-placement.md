# Knowledge Placement Guide

> Routes detected codification signals to the correct destination document and section. Used by the codify-knowledge skill to determine WHERE to write captured knowledge.

## Routing Table

| Signal Type | Destination File | Section | Format |
|------------|-----------------|---------|--------|
| Repeated explanation (architecture) | `constitution.md` | §5 Architectural Summary | Bullet point under "Key architectural decisions" |
| Repeated explanation (convention) | `constitution.md` | §3 Conventions & Standards | Bullet point in appropriate sub-category |
| Repeated explanation (workflow) | `constitution.md` | §6 Operational Checklists | New checklist or addition to existing one |
| Repeated explanation (subsystem detail) | `specs/{subsystem}.md` | Relevant section | Paragraph or section within the spec |
| Debugging breakthrough | `failure-modes.md` | Appropriate category table | New row: Symptom \| Cause \| Fix \| Prevention |
| Architecture decision | `specs/{subsystem}.md` or `constitution.md` §5 | Decision section | Decision record: context, options considered, chosen approach, rationale |
| Gotcha (build/tooling) | `failure-modes.md` | Build & Compile or AI Agent-Specific | New row with prevention guidance |
| Gotcha (convention) | `constitution.md` | §3 Conventions & Standards | Bullet point with warning prefix |
| Gotcha (runtime) | `failure-modes.md` | Runtime Failures | New row with prevention guidance |
| New convention | `constitution.md` | §3 Conventions & Standards | Bullet point in appropriate sub-category |
| Routing discovery | `trigger-tables.md` | File Pattern or Keyword Routing | New row in routing table |
| New subsystem identified | `subsystem-map.md` | Detailed Subsystem Mapping | New table row + boundary section |

## Placement Rules

### Rule 1: Constitution vs. Specs
- **Constitution**: Universal rules, conventions, and summaries that apply project-wide
- **Specs**: Detailed subsystem documentation, complex decisions, implementation details
- **Heuristic**: If it's 1-2 sentences, it belongs in the constitution. If it needs a paragraph or more, create/update a spec.

### Rule 2: Failure Modes vs. Conventions
- **Failure modes**: Things that go WRONG — errors, bugs, unexpected behavior
- **Conventions**: Things to do RIGHT — patterns, standards, approaches
- **Heuristic**: "Don't do X" → failure mode. "Always do Y" → convention.

### Rule 3: Trigger Tables vs. Subsystem Map
- **Trigger tables**: ROUTING logic — which agent/skill/context to invoke
- **Subsystem map**: STRUCTURAL info — what directories map to what subsystems
- **Heuristic**: "When you see X, use Y" → trigger table. "Directory X is part of subsystem Y" → subsystem map.

### Rule 4: Deduplication
Before adding any knowledge:
1. Search the target document for existing coverage
2. If partial coverage exists, UPDATE rather than ADD
3. If the knowledge contradicts existing content, FLAG for human review
4. Never add duplicate entries

## Format Templates

### Failure Mode Entry
```
| {#} | {Error message or behavior observed} | {Root cause explanation} | {Step-by-step fix} | {How to prevent in future} |
```

### Convention Entry
```
- **{Category}**: {Convention description} {rationale in parentheses if non-obvious}
```

### Architecture Decision
```
### Decision: {Title}
- **Context**: {Why this decision was needed}
- **Options**: {What was considered}
- **Chosen**: {What was selected}
- **Rationale**: {Why — trade-offs, constraints, priorities}
```

### Trigger Table Entry
```
| `{file pattern}` | {keywords} | {agent/skill name} | {Why this routing improves outcomes} |
```

## Escalation

If the knowledge doesn't fit neatly into any destination:
1. Default to the constitution §3 (Conventions) for rules
2. Default to failure-modes.md for problems
3. Create a new spec file if the topic is substantial enough
4. Ask the user if placement is unclear
