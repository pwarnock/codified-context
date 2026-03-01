---
name: codify-knowledge
description: Capture debugging insights, repeated explanations, and architecture decisions as durable context. Implements the "explained it twice, write it down" methodology.
---

Analyze the current conversation for knowledge worth codifying into durable context documents.

Use the `codified-context:codify-knowledge` skill to perform a post-session review. The skill will:

1. **Scan** the conversation for codification signals:
   - Repeated explanations of the same concept
   - Debugging breakthroughs (non-obvious root causes)
   - Architecture decisions (chosen approach + rationale)
   - Gotchas and non-obvious constraints
   - New conventions established
   - Routing discoveries (file patterns needing specific agents)

2. **Classify** each signal and route it to the correct destination:
   - Conventions → `constitution.md` §3
   - Failure modes → `failure-modes.md`
   - Architecture decisions → `specs/{subsystem}.md` or constitution §5
   - Routing patterns → `trigger-tables.md`

3. **Draft** proposed additions formatted for each target document

4. **Present** all proposals grouped by target file for your review

5. **Apply** approved additions while maintaining existing document structure

Run this command after productive sessions — especially after debugging, architecture discussions, or establishing new patterns.
