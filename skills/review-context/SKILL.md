---
name: review-context
description: Use when reviewing the health and completeness of a project's context infrastructure, when the user says "review context", "context health", "how complete is my context", or periodically during maintenance. Provides infrastructure inventory, coverage analysis, and quality assessment.
version: 1.0.0
---

**Overview**: Comprehensive review of a project's codified context infrastructure. Evaluates completeness, quality, and coverage to identify gaps and improvements.

**Workflow:**

1. **Infrastructure Inventory**
   - Check which context files exist in .claude/context/
   - Compute completeness score (constitution, trigger tables, failure modes, subsystem map, specs)
   - List any missing core files
   - Count spec files and their sizes

2. **Coverage Analysis**
   - Compare subsystem-map.md against actual directory structure — which subsystems lack documentation?
   - Check trigger-tables.md coverage — what % of source directories have routing rules?
   - Evaluate failure-modes.md entries — how many categories have entries?
   - Cross-reference specs/ with subsystem map — which subsystems lack specs?

3. **Quality Assessment**
   Using criteria from `${CLAUDE_PLUGIN_ROOT}/skills/review-context/references/coverage-criteria.md`:
   - Constitution: All 10 sections populated? Commands verified? Stack current?
   - Trigger tables: Routes specific enough? Rationale provided?
   - Failure modes: Entries have all 4 fields (symptom, cause, fix, prevention)?
   - Subsystem map: Boundaries clear? Dependencies documented?

4. **Growth Metrics** (if git history available)
   - Context files creation date
   - Number of updates since creation
   - Ratio of codebase changes to context updates
   - Session count since last audit

5. **Recommendations Report**
   Generate prioritized recommendations:
   - Critical: Missing core files, broken references
   - High: Undocumented subsystems with recent activity
   - Medium: Stale specs, incomplete failure modes
   - Low: Cosmetic improvements, optional enrichments

6. **Output Format**
   Present as a structured health report with scores and actionable items.
