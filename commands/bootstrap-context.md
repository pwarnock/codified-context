---
name: bootstrap-context
description: Initialize codified context infrastructure for the current project. Creates constitution, trigger tables, failure modes, and subsystem map in .claude/context/.
---

Bootstrap the codified context infrastructure for this project.

Use the `codified-context:bootstrap-context` skill to guide this process. The skill will:

1. **Analyze** the project automatically (type, dependencies, structure, git hotspots)
2. **Ask** 3 key questions to refine the analysis (project purpose, maturity, specialist domains)
3. **Generate** context infrastructure in `.claude/context/`:
   - `constitution.md` — Core project conventions and architecture summary
   - `trigger-tables.md` — File pattern → agent/skill routing intelligence
   - `failure-modes.md` — Known symptom → cause → fix mappings
   - `subsystem-map.md` — Directory → subsystem ownership map
   - `specs/` — Directory for on-demand subsystem documentation
4. **Update** CLAUDE.md with context infrastructure references

All generated content is shown for review before writing. Nothing is written without your approval.

> Based on "Codified Context: Infrastructure for AI Agents in a Complex Codebase" (Vasilopoulos, 2025)
