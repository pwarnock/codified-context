---
name: review-context
description: Review the health and completeness of the project's context infrastructure. Shows coverage analysis, quality scores, and improvement recommendations.
---

Review the codified context infrastructure for this project.

Use the `codified-context:review-context` skill to perform a comprehensive health check. The skill will:

1. **Inventory** the context infrastructure — which files exist, what's missing
2. **Analyze coverage** — which subsystems lack documentation, which have routing gaps
3. **Assess quality** — are constitution sections complete? Do failure modes have all fields?
4. **Track growth** — how has the context infrastructure evolved over time
5. **Recommend** prioritized improvements:
   - Critical: Missing core files, broken references
   - High: Undocumented active subsystems
   - Medium: Stale specs, incomplete entries
   - Low: Cosmetic improvements

Use this command for:
- Monthly maintenance reviews
- Before major feature work (ensure context is current)
- After onboarding the context infrastructure (verify bootstrap quality)
- When context feels "off" and you want a systematic check
