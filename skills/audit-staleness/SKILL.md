---
name: audit-staleness
description: Use when checking if project context documents are stale or outdated, when the user says "audit staleness", "check context drift", "are my docs current", or when the session-start hook detected drift. Performs deep analysis of all context documents against current codebase state.
version: 1.0.0
---

## Prerequisites

Before beginning the audit, verify the context infrastructure exists:

1. Check that `.claude/context/` exists in the project root
2. If it does not exist, stop and inform the user: "This project doesn't have codified context infrastructure yet. Run /bootstrap-context to set it up first."
3. Note the path to `drift-patterns.md` at `${CLAUDE_PLUGIN_ROOT}/skills/audit-staleness/references/drift-patterns.md` — use it throughout this audit to classify findings

---

## Step 1: File Existence Check

Scan each context document for referenced file paths and verify they still exist on disk.

**Documents to scan**: `constitution.md`, `trigger-tables.md`, `subsystem-map.md`, all files under `specs/`

For each document:
- Extract all file paths (look for patterns like `src/`, `lib/`, `pkg/`, quoted paths, backtick-wrapped paths, and Markdown code spans containing `/`)
- For each extracted path, check if the file or directory exists
- Record: document name, referenced path, exists (yes/no)

Summarize: "X of Y referenced paths are broken" per document.

---

## Step 2: Function Signature Validation

For key functions and interfaces mentioned in spec files under `specs/`:

1. Identify function names, method signatures, and type definitions cited in the specs (look for code blocks, backtick-wrapped identifiers, and explicit "signature:" or "interface:" labels)
2. Search the codebase for the actual current definition of each identified symbol
3. Compare the spec's version against the live version
4. Flag any mismatches as API Drift (see drift-patterns.md §2)

Focus on high-impact symbols: exported functions, public interfaces, route handlers, and configuration schemas.

---

## Step 3: Build Command Verification

Locate the build, test, and lint commands recorded in `constitution.md` §4 (or equivalent "Commands" section).

For each command:
- Run it with `--help` or `--dry-run` if the tool supports it, or check that the binary/script exists
- If the command is a script path (e.g., `./scripts/build.sh`), verify the file exists and is executable
- If the command references a package manager task (e.g., `bun run build`), verify the task is defined in the relevant config file
- Flag missing or broken commands as Command Drift (see drift-patterns.md §5)

Do NOT run commands that modify state (no `build`, `deploy`, `migrate`). Only verify existence and basic validity.

---

## Step 4: Staleness Scoring

Compute a staleness score for each context document. Use the heuristics table in `drift-patterns.md` (Green / Yellow / Red thresholds).

For each document, calculate:

| Dimension | How to measure | Weight |
|-----------|---------------|--------|
| Document age | Days since last `git log` modification date | 25% |
| Path validity | % of referenced paths that still exist | 40% |
| Git coverage | % of subsystems with recent git changes that have updated docs | 25% |
| Command validity | % of referenced commands that are still valid | 10% |

Combine into a per-document score (0–100, higher = healthier). Use the thresholds:
- Green (80–100): Healthy
- Yellow (50–79): Needs attention
- Red (0–49): Stale — action required

---

## Step 5: Drift Report

Present a structured report with the following sections:

### Overall Health Score
A single weighted average across all documents. State the score and its color band.

### Per-Document Staleness Scores
A table:

```
| Document              | Age  | Paths   | Coverage | Commands | Score | Status |
|-----------------------|------|---------|----------|----------|-------|--------|
| constitution.md       | 12d  | 100%    | 80%      | 100%     | 91    | Green  |
| subsystem-map.md      | 45d  | 72%     | 40%      | n/a      | 53    | Yellow |
| specs/auth.md         | 60d  | 60%     | 20%      | n/a      | 38    | Red    |
```

### Stale References
List every broken path or mismatched signature with:
- Document and line number (if determinable)
- The stale reference
- Suggested fix (updated path, updated signature, or "remove if obsolete")

Classify each finding using the drift categories from `drift-patterns.md`.

### Subsystems with Outdated Docs
Cross-reference `subsystem-map.md` against recent git history (last 30 days). For each subsystem that had code changes but no corresponding doc update, flag it with the files changed and the doc that should have been updated.

---

## Step 6: Remediation

For each Red-status document and each High-severity finding:

1. Propose a specific diff or edit that would fix the stale reference
2. Present the proposed fix clearly, showing old vs. new
3. Ask the user: "Shall I apply this fix?" before making any changes
4. Apply only fixes the user explicitly approves

After applying fixes, re-run the affected dimension check (path existence, command validity) to confirm the fix resolved the issue.

For Yellow-status documents with no immediate blockers, summarize the recommended maintenance actions and suggest scheduling them.

---

## Reference

Consult `${CLAUDE_PLUGIN_ROOT}/skills/audit-staleness/references/drift-patterns.md` for:
- Detailed descriptions of each drift category
- Staleness heuristic thresholds (Green/Yellow/Red)
- Priority matrix for sequencing remediation work
