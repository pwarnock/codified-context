---
name: context-routing
description: Use when deciding which agent, skill, or context document to invoke for a given file or task. Consults trigger tables to route work to the right specialist. Activated automatically when working in a project with codified context infrastructure.
version: 1.0.0
---

**Overview**: This skill teaches the AI how to use trigger tables for intelligent routing. When working in a project with .claude/context/trigger-tables.md, consult it to load the right context at the right time.

**Routing Decision Flow:**

1. **On file open/edit**:
   - Read the file path being worked on
   - Match against File Pattern Routing in trigger-tables.md
   - If match found: load the corresponding spec document, invoke the recommended agent/skill
   - If no match: continue with general context

2. **On keyword detection**:
   - Scan conversation for keywords defined in Keyword Routing
   - If match found: load the specified context document
   - Multiple matches: load all matching contexts

3. **On subsystem entry**:
   - When working in a subsystem directory, check Subsystem Routing
   - Load the corresponding spec document for that subsystem
   - Note the owner agent if defined

4. **Routing precedence**:
   - Explicit user request > File pattern match > Keyword match > Subsystem match
   - More specific patterns take priority over broader ones
   - Recently loaded context doesn't need reloading

**When to reload context:**
- Switching between subsystems
- Starting a new task in the same session
- After committing changes (context may have shifted)

**When trigger tables don't exist:**
- If .claude/context/trigger-tables.md doesn't exist, this skill is a no-op
- Suggest running /bootstrap-context to enable routing
