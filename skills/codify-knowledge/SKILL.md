---
name: codify-knowledge
description: Use when capturing debugging insights, repeated explanations, architecture decisions, or gotchas as durable context. Use when the user says "codify this", "write this down", "remember this", "capture knowledge", or after debugging sessions. Implements the "explained it twice, write it down" methodology.
version: 1.0.0
---

## Overview

This skill captures knowledge from conversations and codifies it into the appropriate context document. It implements the paper's key heuristic: "if you explained it twice, write it down."

## Two Modes of Operation

### Mode 1: Inline Detection (during regular work)

Self-detect codification signals during normal conversation:

- "I just explained this same concept for the second time" → propose addition to constitution or relevant spec
- "We just spent 20+ minutes debugging this" → propose addition to failure-modes.md
- "We just made an architecture decision" → propose addition to relevant spec or constitution §5
- "I found a non-obvious constraint/gotcha" → propose addition to constitution §3 or §7
- "We established a new convention" → propose addition to constitution §3
- "I recommended a specific agent/skill for this file pattern" → propose addition to trigger-tables.md

When detecting a signal: state what was detected, propose the specific diff, reference which document section, wait for approval.

### Mode 2: Post-Session Review (via /codify-knowledge command)

Full conversation analysis workflow:

1. Read the conversation transcript (use the transcript_path if available, or analyze current conversation context)
2. Scan for codification signals using the patterns in `${CLAUDE_PLUGIN_ROOT}/skills/codify-knowledge/references/codification-signals.md`
3. For each detected signal:
   a. Classify it (repeated explanation, debugging breakthrough, architecture decision, gotcha, new convention)
   b. Route it to the correct destination using `${CLAUDE_PLUGIN_ROOT}/skills/codify-knowledge/references/knowledge-placement.md`
   c. Draft the specific addition (formatted for the target document)
4. Present all proposed additions grouped by target document
5. Apply approved additions (with proper formatting for each target document's structure)
6. Report what was codified and where

## Important Rules

- Never write without approval (show proposed diff first)
- Keep additions concise — link to specs/ for details
- Maintain existing document structure (add to correct sections, preserve table formats)
- If .claude/context/ doesn't exist, suggest running /bootstrap-context first
- De-duplicate: check if the knowledge already exists before proposing
