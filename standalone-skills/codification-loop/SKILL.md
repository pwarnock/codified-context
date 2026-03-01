---
name: codification-loop
description: Use when capturing knowledge from conversations into durable context documents. Implements the "explained it twice, write it down" methodology for AI coding agents. Use when the user says "write this down", "remember this", "codify this", or when you detect repeated explanations, debugging breakthroughs, or architecture decisions.
version: 1.0.0
---

# Codification Loop

## Overview

The codification loop is the paper's core behavioral heuristic: "If you explained it twice, write it down." It turns ephemeral conversation knowledge into durable context that persists across sessions.

The fundamental problem it solves: AI coding agents start every session with no memory of previous sessions. Knowledge discovered, bugs debugged, and decisions made in one session evaporate. The codification loop is the discipline that prevents this — capturing knowledge at the moment it emerges and writing it into the context documents that persist.

The loop does not require automation. It requires the AI agent to self-monitor during work and propose knowledge capture at the right moments.

---

## The Loop

### 1. Detect

Watch for signals during conversation that indicate durable knowledge has emerged. These signals fall into six categories: repeated explanations, debugging breakthroughs, architecture decisions, gotchas, new conventions, and routing discoveries.

The detection burden is on the AI agent. It should be actively monitoring the conversation for these patterns rather than waiting for the user to say "write this down." See `references/codification-signals.md` for detailed signal patterns and urgency ratings.

### 2. Classify

Determine what type of knowledge has emerged. This classification determines both the destination document and the format of the entry. The main types are:

- **Convention** — a rule to follow consistently going forward
- **Failure mode** — something that goes wrong and how to fix it
- **Architecture decision** — a design choice made between alternatives
- **Gotcha** — a non-obvious constraint or behavior
- **Routing pattern** — a file pattern or keyword that needs specialized handling

### 3. Route

Determine which context document the knowledge belongs in. The routing is determined by the classification:

- Conventions → `constitution.md` §3 (Conventions & Standards)
- Failure modes → `failure-modes.md` (appropriate category table)
- Architecture decisions → `specs/{subsystem}.md` or `constitution.md` §5
- Routing patterns → `trigger-tables.md`

See `references/knowledge-placement.md` for the complete routing table with formats.

### 4. Draft

Write the addition in the target document's existing format. Do not invent new formats — match the tables, bullet points, and section structure already in the document. Keep entries concise: 1-3 sentences per entry is the target. Link to specs for anything that needs more detail.

### 5. Approve

Show the proposed addition to the user before writing. Quote the destination section, show exactly what the new entry would look like, and ask for confirmation. Do not write to the file until the user approves. This keeps the user in control and prevents low-quality entries from accumulating.

### 6. Apply

Write to the correct file and section. If the file does not exist yet, note that it needs to be created. After writing, confirm the addition was made.

---

## Signal Detection (Inline During Work)

The AI agent should self-detect these patterns while working, not just when asked:

**"I just explained this concept for the second time"**
This is the primary signal. If the same API, constraint, pattern, or decision has come up twice in the conversation, it belongs in the constitution or a spec. Urgency: high — repeated explanations waste tokens and indicate missing context.

**"We spent significant time debugging this"**
Multiple hypothesis-test cycles, non-obvious root causes, environment-specific issues. The debugging breakthrough is the most valuable knowledge to capture because it prevents re-discovery. Urgency: high.

**"We made a design choice between alternatives"**
Any time the conversation includes "we should use X instead of Y because..." or weighing trade-offs. Architecture decisions that get revisited waste significant time. Urgency: medium.

**"I found something non-obvious about this codebase"**
Framework quirks, edge cases, ordering dependencies, counterintuitive behaviors. These are the most common source of repeated AI mistakes. Urgency: medium-high.

**"We established how to do X going forward"**
Naming conventions, file organization patterns, API patterns, workflow steps. Once a convention is established, it should be in the constitution immediately. Urgency: medium.

**"Whenever we work on files in X, we need to..."**
A routing discovery — a file pattern or keyword that consistently needs specialized handling. Urgency: low-medium.

See `references/codification-signals.md` for detailed patterns, indicators, and urgency ratings for each signal category.

---

## Knowledge Routing

Where to put what you capture:

| Signal Type | Destination | Section |
|------------|-------------|---------|
| Convention | `constitution.md` | §3 Conventions & Standards |
| Failure mode | `failure-modes.md` | Appropriate category table |
| Architecture decision | `specs/{subsystem}.md` | Decision section |
| Gotcha (build/tooling) | `failure-modes.md` | Build & Compile or AI Agent-Specific |
| Gotcha (convention) | `constitution.md` | §3 Conventions & Standards |
| Routing pattern | `trigger-tables.md` | File Pattern or Keyword Routing |

See `references/knowledge-placement.md` for the full routing table, format templates for each entry type, and placement rules.

---

## Best Practices

**Capture in the same session it emerges.** The paper's guideline G2 specifically emphasizes this: "Codify debugging insights within the session." The context is freshest immediately after the discovery. Waiting produces lower-quality entries.

**Keep entries concise.** 1-3 sentences per entry. If an entry needs more than that, it probably belongs in a spec file rather than the constitution. Link rather than inline.

**Match the target document's existing format.** If failure-modes.md uses a four-column table, add a four-column table row. Do not invent new structures — consistency makes the documents scannable.

**De-duplicate before adding.** Search the target document for existing coverage before proposing an addition. If partial coverage exists, update rather than add. Duplicate entries undermine trust in the documents.

**When in doubt about placement:**
- If it's a rule to follow → `constitution.md` §3
- If it's something that goes wrong → `failure-modes.md`
- If it needs a paragraph to explain → create or update a spec

**Do not codify:**
- Temporary state ("the server is down right now")
- Obvious facts that any developer would know from reading the code
- Personal preferences not adopted as team conventions
- Speculative patterns — wait for the second occurrence
- Session-specific context like current task details
