# Context Coverage Criteria

> Quality rubrics for evaluating codified context documents. Used by the review-context skill to assess infrastructure health.

## Constitution Quality Rubric

| Section | Complete | Partial | Missing | Weight |
|---------|----------|---------|---------|--------|
| §1 Project Objectives | Purpose, users, outcomes defined | Some fields empty | Section absent | 10% |
| §2 Technology Stack | All layers with versions | Some layers missing | Section absent | 10% |
| §3 Conventions | 3+ conventions documented | 1-2 conventions | Section absent | 15% |
| §4 Build Commands | All commands verified working | Commands listed but unverified | Section absent | 15% |
| §5 Architecture | Summary + key decisions | Summary only | Section absent | 10% |
| §6 Checklists | 2+ checklists with items | 1 checklist | Section absent | 10% |
| §7 Failure Modes | Top 3 linked to failure-modes.md | Some listed | Section absent | 10% |
| §8 Trigger Tables | Summary linked to trigger-tables.md | Mentioned | Section absent | 5% |
| §9 Codification Protocol | Signal list + workflow | Partially described | Section absent | 10% |
| §10 Maintenance Schedule | Schedule + last-reviewed date | Schedule only | Section absent | 5% |

## Trigger Table Quality Rubric

| Criterion | Good | Adequate | Poor |
|-----------|------|----------|------|
| Coverage | Routes for >80% of source dirs | 50-80% coverage | <50% coverage |
| Specificity | Patterns match narrow file sets | Some overly broad patterns | Mostly wildcards |
| Rationale | Every route has documented rationale | Most have rationale | No rationale |
| Keyword routing | 5+ keyword routes defined | 1-4 routes | No keyword routing |
| Freshness | Updated within 14 days | Updated within 30 days | >30 days stale |

## Failure Modes Quality Rubric

| Criterion | Good | Adequate | Poor |
|-----------|------|----------|------|
| Entry count | 5+ entries across categories | 2-4 entries | 0-1 entries |
| Completeness | All 4 fields (symptom/cause/fix/prevention) | 3 fields | <3 fields |
| Specificity | Error messages quoted, steps numbered | General descriptions | Vague references |
| Categories | 3+ categories with entries | 1-2 categories | Single flat list |
| Lifecycle | Archived section used | Entries reviewed | No maintenance |

## Subsystem Map Quality Rubric

| Criterion | Good | Adequate | Poor |
|-----------|------|----------|------|
| Coverage | All source directories mapped | Major directories mapped | Partial mapping |
| Boundaries | Purpose, key files, API, dependencies | Purpose + key files | Name only |
| Specs linked | Every subsystem has a spec | >50% have specs | No specs |
| Hot areas | Auto-populated, current | Populated but stale | Missing |
| Cross-cutting | Concerns documented | Partially documented | Missing |

## Overall Health Score

Calculate the weighted average across all documents:

| Score | Rating | Interpretation |
|-------|--------|---------------|
| 90-100 | Excellent | Context infrastructure is comprehensive and current |
| 70-89 | Good | Core documents solid, some gaps in coverage or freshness |
| 50-69 | Fair | Foundational docs exist but need significant enrichment |
| 30-49 | Poor | Major gaps — several core documents missing or very stale |
| 0-29 | Critical | Context infrastructure barely exists — run /bootstrap-context |

## Improvement Priority

When recommending improvements, prioritize:
1. **Missing core files** → Run bootstrap to create them
2. **Broken references** → Fix immediately (high confusion risk)
3. **Stale build commands** → Verify and update (blocks agent workflow)
4. **Undocumented active subsystems** → Write specs for frequently changed areas first
5. **Incomplete failure modes** → Add entries from recent debugging sessions
6. **Routing gaps** → Add trigger table entries for undocumented patterns
7. **Quality improvements** → Fill in missing fields, add rationale, update dates
