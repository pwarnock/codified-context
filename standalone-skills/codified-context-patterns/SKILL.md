---
name: codified-context-patterns
description: Use when setting up or understanding the three-tier codified context framework for AI coding agents. Provides the constitution template, trigger table format, failure modes format, and subsystem map format. Use when the user says "set up context", "create a constitution", "what is codified context", or wants to manually build persistent context infrastructure.
version: 1.0.0
---

# Codified Context Patterns

## Overview

The three-tier codified context framework comes from the paper "Codified Context" (Vasilopoulos, 2025). It provides a structured approach to giving AI coding agents persistent, session-spanning knowledge about a codebase — without loading everything every time.

The three tiers:

**Tier 1: Hot Memory (Constitution)**
Loaded every session. Contains core conventions, tech stack, build commands, and an architecture summary. Kept concise — target 1-2 pages. This is the document the AI agent reads at the start of every conversation. Even a minimal constitution dramatically improves agent behavior.

**Tier 2: Routing Intelligence (Trigger Tables)**
Maps file patterns and keywords to the right agent, skill, or context document. When the AI opens a file in `src/api/`, the trigger table tells it to load the API spec and invoke the API specialist. Enables selective loading — the AI only loads what it needs for the current task.

**Tier 3: Cold Memory (Specs)**
On-demand subsystem documentation. Only loaded when the AI is actively working in that subsystem. Lives in `specs/` and is referenced from trigger tables and the constitution. Allows detailed documentation without bloating the hot memory.

---

## Manual Setup Guide

You do not need a plugin or automation to get started. The infrastructure is just a set of Markdown files in a known location.

### Step 1: Create the directory structure

```
.claude/
└── context/
    ├── constitution.md
    ├── trigger-tables.md
    ├── failure-modes.md
    ├── subsystem-map.md
    └── specs/
```

```bash
mkdir -p .claude/context/specs
```

### Step 2: Create `constitution.md`

Copy `references/constitution-template.md` and fill in sections 1-6 first. The rest grows organically over time. Focus on:
- What the project does and who uses it (§1)
- Your exact tech stack with versions (§2)
- Non-obvious conventions the AI must follow (§3)
- Verified build, test, and lint commands (§4)
- A 3-5 sentence architecture summary (§5)

See: `references/constitution-template.md`

### Step 3: Create `trigger-tables.md`

Start with 3-5 routes covering your main source directories. You do not need comprehensive coverage on day one — add routes when you notice the AI is missing context it needs.

See: `references/trigger-table-template.md`

### Step 4: Create `failure-modes.md`

Start empty — just copy the template with its category headings. Populate it after your first debugging session. The format is a simple table: Symptom | Cause | Fix | Prevention.

See: `references/failure-modes-template.md`

### Step 5: Create `subsystem-map.md`

Map your top-level source directories to logical subsystems. Even a rough directory tree with one-line descriptions is better than nothing.

See: `references/subsystem-map-template.md`

### Step 6: Create the `specs/` directory

Leave it empty for now. Write specs when a subsystem gets complex enough that you find yourself re-explaining it frequently.

```bash
mkdir -p .claude/context/specs
```

### Step 7: Reference the context from CLAUDE.md

Add a section to your `CLAUDE.md` so the AI knows where to look:

```markdown
## Context Infrastructure

Project context is maintained in `.claude/context/`. At the start of every session:
1. Read `constitution.md` — core conventions, tech stack, architecture
2. Check `trigger-tables.md` — route file patterns and keywords to the right context
3. Load relevant `specs/` documents when working in a specific subsystem
4. Consult `failure-modes.md` before debugging unfamiliar errors
```

### Step 8: Create `.last-session-check`

Record the current git SHA so staleness detection can compare future sessions:

```bash
git rev-parse HEAD > .claude/context/.last-session-check
```

---

## Template References

### Constitution Template

`references/constitution-template.md`

A 10-section template covering: Project Objectives, Technology Stack, Conventions & Standards, Build & Run Commands, Architectural Summary, Operational Checklists, Known Failure Modes, Trigger Table Reference, Codification Protocol, and Maintenance Schedule.

Fill in sections 1-6 on initial setup. Sections 7-10 are populated as you use the system. The codification protocol section (§9) tells the AI when and how to propose knowledge capture during sessions.

### Trigger Table Template

`references/trigger-table-template.md`

Three routing tables: File Pattern Routing (maps directory patterns to agents/skills), Keyword Routing (maps conversation keywords to context documents), and Subsystem Routing (maps subsystems to spec documents). Start with the file pattern table covering your main source directories.

### Failure Modes Template

`references/failure-modes-template.md`

Five category tables: Critical Failures, Build & Compile Failures, Runtime Failures, Test Failures, and AI Agent-Specific Failures. Each row captures: symptom, cause, fix, and prevention. The AI Agent-Specific category is particularly valuable — it documents failure patterns unique to AI-assisted development (e.g., "agent edits generated file directly").

### Subsystem Map Template

`references/subsystem-map-template.md`

Directory-to-subsystem mapping with a visual tree, a detailed table, per-subsystem boundary sections, cross-cutting concerns, and a hot areas table for high-churn directories.

---

## The Paper's Key Findings

Evaluated across 283 sessions on a 108K-line C# codebase.

**G1: "A basic constitution does heavy lifting"**
Even a minimal constitution — just tech stack, conventions, and build commands — dramatically reduces agent mistakes. The constitution is the highest-leverage context document. Start here before anything else.

**G2: "Codify debugging insights within the session"**
Knowledge captured immediately after a debugging breakthrough is the highest quality — the context is fresh and the root cause is understood. Waiting until later produces lower-quality entries. Capture failure modes in the same session they emerge.

**G3: "Use routing to manage complexity"**
As a codebase grows, loading all context every session becomes expensive and noisy. Trigger tables let the AI load only what it needs for the current task. Start routing infrastructure early, before context becomes unwieldy.

**Eliminated failure categories:**
- Re-discovery of known bugs (addressed by failure-modes.md)
- Recurring convention violations (addressed by constitution §3)
- Context overload causing missed details (addressed by trigger tables + selective loading)

---

## Growing the Infrastructure

The framework is designed to grow incrementally. You do not need to fill everything in on day one.

**Add failure modes after every debugging session.** When you spend significant time on a bug, capture the symptom, cause, fix, and prevention before closing the conversation. This is the highest-value maintenance activity.

**Add trigger table routes when you notice gaps.** If you find yourself repeatedly telling the AI to load a specific document or explaining the same subsystem context, that's a signal to add a route.

**Write specs when a subsystem gets complex.** The threshold is roughly: "If explaining this subsystem takes more than 2-3 sentences, it deserves a spec." Write specs for the subsystems you change most frequently first.

**Review and prune monthly.** Remove archived failure modes, verify build commands still work, check that tech stack versions are current. A stale constitution is worse than a minimal one because it misleads the agent.
