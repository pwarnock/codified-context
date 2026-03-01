---
name: audit-staleness
description: Check if project context documents are stale or outdated. Detects drift between codebase state and context documentation.
---

Audit the codified context infrastructure in this project for staleness and drift.

Use the `codified-context:audit-staleness` skill to perform a deep audit. The skill will:

1. **Verify** all file paths referenced in context documents still exist
2. **Check** build/test/lint commands from the constitution are still valid
3. **Analyze** git history to find subsystems with changes but outdated documentation
4. **Score** each context document for staleness (age, path validity, git coverage)
5. **Report** findings with a structured health report
6. **Propose** specific fixes for stale references (applied only with your approval)

This is more thorough than the automatic session-start check — use it when:
- The session-start hook flagged potential drift
- Before a major refactoring effort
- During scheduled maintenance (recommended: every 2 weeks)
- When onboarding a new team member
