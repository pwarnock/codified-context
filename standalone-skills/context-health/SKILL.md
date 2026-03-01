---
name: context-health
description: Use when evaluating the quality and completeness of a project's codified context infrastructure. Provides rubrics for scoring constitution, trigger tables, failure modes, and subsystem map quality. Use when the user says "check context health", "how good is my context", "score my context", or during periodic maintenance reviews.
version: 1.0.0
---

# Context Health

## Overview

Quality rubrics and evaluation methodology for codified context infrastructure. Use this to assess whether your context documents are serving their purpose and identify improvement opportunities.

A context infrastructure that exists but is inaccurate or stale can be worse than no infrastructure — it actively misleads the AI agent. Regular health evaluation catches drift before it becomes a problem.

---

## Quick Health Check (5-minute version)

Run through these five questions to get a rough health score:

1. Does `.claude/context/constitution.md` exist and have all 10 sections filled in?
   - All 10 sections, all non-placeholder content: **10 points**
   - Exists but sections are incomplete or contain template placeholders: **5 points**
   - Missing: **0 points**

2. Does `trigger-tables.md` have routes for your main source directories?
   - Routes covering >80% of source directories: **5 points**
   - Some routes, partial coverage: **2-3 points**
   - Missing or no routes: **0 points**

3. Does `failure-modes.md` have entries from recent debugging sessions?
   - 5+ entries across multiple categories: **5 points**
   - 2-4 entries: **2-3 points**
   - Empty or missing: **0 points**

4. Does `subsystem-map.md` cover all major directories?
   - All source directories mapped with boundary sections: **5 points**
   - Major directories mapped: **2-3 points**
   - Missing or mostly empty: **0 points**

5. Do `specs/` exist for your most-changed subsystems?
   - Specs exist for high-churn subsystems: **5 points**
   - Some specs, not the high-churn ones: **2-3 points**
   - No specs: **0 points**

**Total: /30**

Map to health rating:
- 27-30: Excellent
- 21-26: Good
- 15-20: Fair
- 9-14: Poor
- 0-8: Critical

---

## Detailed Quality Assessment

For a thorough evaluation, score each document against the rubrics in `references/coverage-criteria.md`. The rubrics cover:

- **Constitution quality** — per-section scoring with Complete / Partial / Missing ratings and section weights
- **Trigger table effectiveness** — coverage breadth, pattern specificity, rationale completeness, freshness
- **Failure mode completeness** — entry count, field completeness, specificity, category coverage, lifecycle maintenance
- **Subsystem map accuracy** — directory coverage, boundary documentation, spec linkage, hot area tracking

---

## Health Scoring

| Score | Rating | Interpretation |
|-------|--------|---------------|
| 90-100 | Excellent | Context infrastructure is comprehensive and current |
| 70-89 | Good | Core documents solid, some gaps in coverage or freshness |
| 50-69 | Fair | Foundational docs exist but need significant enrichment |
| 30-49 | Poor | Major gaps — several core documents missing or very stale |
| 0-29 | Critical | Context infrastructure barely exists — run bootstrap setup |

---

## Improvement Priorities

When the health check reveals gaps, address them in this order:

1. **Missing core files** — Create them, even minimal versions. The paper's guideline G1 ("a basic constitution does heavy lifting") applies here: even a minimal constitution is dramatically better than none. Run through the bootstrap setup guide from `codified-context-patterns`.

2. **Broken references** — Links in the constitution that point to non-existent spec files, or trigger table routes pointing to missing context documents. Fix immediately — broken references cause the AI to fail silently.

3. **Stale build commands** — Build commands that no longer work are the most immediately damaging stale content. The AI will run them and fail. Verify every command in §4 actually executes successfully.

4. **Undocumented active subsystems** — Write specs for high-churn subsystems first. The areas you change most frequently have the highest leverage for improvement. Check git log to identify high-churn directories.

5. **Incomplete failure modes** — Add entries from recent debugging sessions. If you can recall debugging anything in the last month that took more than 30 minutes, it probably belongs in failure-modes.md.

6. **Routing gaps** — Add trigger table entries for file patterns and keywords that you find yourself repeatedly context-switching around. If you're loading the same spec manually every time you work in a directory, add the route.

7. **Quality improvements** — Fill in missing fields in failure mode entries (especially the Prevention column), add rationale to trigger table rows that lack it, update last-reviewed dates.

---

## Maintenance Cadence

**Every 2 weeks**: Review failure modes. Remove entries where the root cause has been permanently fixed (move to the Archived section). Add entries from any debugging sessions since the last review.

**Monthly**: Check tech stack versions in §2 against your actual installed versions. Verify build commands in §4 still work. Versions drift, commands change, package managers update.

**After major refactors**: Review the architecture summary in §5 and the trigger tables in §8. Structural changes to the codebase mean routing rules may be pointing at moved or deleted directories.

**After onboarding new agents or skills**: Update the trigger tables. New agents/skills should have routing entries so the AI knows when to invoke them.
