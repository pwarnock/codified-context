---
name: bootstrap-context
description: Use when setting up persistent context infrastructure for a project, when the user says "bootstrap context", "set up context", "initialize codified context", or when a project lacks .claude/context/ directory. Creates constitution, trigger tables, failure modes, and subsystem map.
version: 1.0.0
---

## Overview

This skill creates the three-tier context infrastructure described in "Codified Context: Infrastructure for AI Agents in a Complex Codebase" (Vasilopoulos, 2025):

- **Tier 1 — Hot memory (constitution)**: `constitution.md` — loaded every session. Project objectives, tech stack, conventions, build commands, architecture, and self-maintenance protocol. The AI agent reads this first, every time.
- **Tier 2 — Routing intelligence (trigger tables + failure modes)**: `trigger-tables.md` routes file patterns and keywords to the right specialist. `failure-modes.md` maps symptoms to causes to fixes, eliminating repeated debugging.
- **Tier 3 — Cold memory (specs + subsystem map)**: `subsystem-map.md` catalogues directory ownership. `specs/` holds on-demand subsystem documentation loaded only when entering that subsystem.

**Goal**: eliminate context loss between sessions, prevent the AI agent from re-diagnosing the same failures, and route work to the appropriate specialist automatically.

The output is a `.claude/context/` directory in the project root containing all infrastructure files, plus a reference block appended to the project's CLAUDE.md.

---

## Section 1: Prerequisites Check

Before generating any files, verify the environment:

1. **Confirm you are in a project directory.** Check that source files exist (not just an empty or home directory). If the directory appears to be non-project (no recognizable source files, config files, or version control), stop and ask the user to `cd` into their project root first.

2. **Check for existing context infrastructure.** Run:
   ```bash
   ls -la .claude/context/ 2>/dev/null
   ```
   - If `.claude/context/` exists and contains files, do NOT overwrite. Instead, tell the user: "Context infrastructure already exists. Run `/audit-staleness` to check for drift, or tell me to overwrite if you want to regenerate from scratch."
   - If `.claude/context/` exists but is empty, proceed with generation.
   - If `.claude/context/` does not exist, proceed with generation.

3. **Check for an existing CLAUDE.md.** Run:
   ```bash
   ls -la CLAUDE.md .claude/CLAUDE.md 2>/dev/null
   ```
   Note whether one exists and where — you will append to it in Section 6. If neither exists, you will create `CLAUDE.md` in the project root.

---

## Section 2: Auto-Analysis Phase

Run the repository analyzer to gather structured project data. Use the Bash tool:

```bash
${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-context/scripts/analyze-repo.sh "$(pwd)"
```

The script outputs JSON with these fields:
- `project_type` — detected language/ecosystem (e.g., `nodejs`, `go`, `python`, `rust`)
- `package_manager` — e.g., `bun`, `go`, `cargo`, `uv`
- `build_commands` — object with `install`, `dev`, `build`, `test`, `lint`, `typecheck` (null if not found)
- `directory_structure` — array of `{ path, file_count }` for top-level directories (excluding noise like `node_modules`, `.git`, `dist`)
- `git_hotspots` — array of `{ path, commit_count }` for the most-changed directories in the last 30 days (empty array if not a git repo)
- `existing_claude_config` — `{ claude_md, settings, agents, skills }` booleans
- `language_files` — object mapping file extension to count
- `dependencies_count` — total direct dependency count
- `has_tests` — boolean
- `has_ci` — boolean

If the script fails (e.g., `jq` not installed), note the error and proceed with manual analysis: examine `directory_structure` by running `ls -la`, detect project type from config files, and set `build_commands` to null values.

Additionally:

- Read `CLAUDE.md` (or `.claude/CLAUDE.md`) if it exists using the Read tool. Extract any existing conventions, commands, or architecture notes to carry forward into the constitution.
- Check for existing agents and skills directories:
  ```bash
  ls .claude/agents/ 2>/dev/null; ls .claude/skills/ 2>/dev/null
  ```
  Note any specialist agents already defined — these will populate the trigger tables.

**Present a structured summary to the user before proceeding:**

```
Analysis complete:

Project type:     [project_type]
Package manager:  [package_manager]
Dependencies:     [dependencies_count]
Tests found:      [has_tests]
CI configured:    [has_ci]

Top-level directories:
  [list each path with file count]

Git hotspots (30d):
  [list each path with commit count, or "not a git repo"]

Detected build commands:
  Install:    [cmd or "not detected"]
  Dev:        [cmd or "not detected"]
  Build:      [cmd or "not detected"]
  Test:       [cmd or "not detected"]
  Lint:       [cmd or "not detected"]
  Typecheck:  [cmd or "not detected"]

Existing Claude config:
  CLAUDE.md:  [yes/no]
  settings:   [yes/no]
  agents:     [yes/no, list if found]
  skills:     [yes/no, list if found]
```

---

## Section 3: Interactive Refinement

Ask the user three questions before generating files. Use the AskUserQuestion tool for each. Wait for each answer before proceeding to the next.

### Question 1: Project Purpose

Present what the analyzer inferred, then ask the user to refine it:

> "Based on analysis, I've inferred this project is a [project_type] project. Before I generate the constitution, I need to understand its purpose more precisely.
>
> Please describe:
> 1. What does this project do? (one or two sentences)
> 2. Who uses it? (e.g., internal team, external customers, API consumers, CLI users)
> 3. What does success look like? (e.g., shipped features, uptime SLA, test coverage target)
>
> Pre-filled from analysis: [any relevant clues from directory names, package.json description, README if found]
> You can accept this, correct it, or replace it entirely."

Store the answer as `user_purpose`.

### Question 2: Codebase Maturity

> "How mature is this codebase? This affects how much convention documentation I generate.
>
> Options:
> - **Greenfield** — New project, conventions are being established. I'll scaffold opinionated defaults and mark them as TBD.
> - **Active Development** — Ongoing project with evolving conventions. I'll document what's detected and flag areas needing clarification.
> - **Mature/Stable** — Established conventions and architecture. I'll document thoroughly and treat detected patterns as authoritative.
> - **Legacy** — Older codebase, possibly with inconsistent conventions. I'll document what exists and add warnings where patterns conflict.
>
> Which best describes the codebase?"

Store the answer as `user_maturity`. This affects:
- **Greenfield**: Mark most constitution sections as "TBD — establish convention and update this file"
- **Active Development**: Fill from analysis, add "Review needed" comments on ambiguous sections
- **Mature/Stable**: Fill confidently from analysis, minimize TBD markers
- **Legacy**: Fill from analysis, add explicit warnings on inconsistencies

### Question 3: Specialist Routing Domains

Present the detected subsystems, then ask:

> "I detected these top-level directories that may benefit from specialist routing:
> [list directories from analysis with file counts]
>
> Which of these areas have distinct conventions, patterns, or complexity that would benefit from a dedicated specialist agent?
>
> For example:
> - A `db/` or `migrations/` directory often needs database-aware agents
> - A `frontend/` or `components/` directory needs UI-aware agents
> - An `api/` or `routes/` directory needs HTTP/auth-aware agents
>
> List the subsystems you want specialist routing for (you can say 'all', 'none', or name specific ones). If you have existing agents in `.claude/agents/`, I'll map them automatically."

Store the answer as `user_routing_domains`. Cross-reference with any existing agents found in `.claude/agents/` — map those agent names into the trigger tables for their matching directory patterns.

---

## Section 4: Artifact Generation

Before writing any file, show the user the proposed content and get confirmation. Do not write files silently.

Tell the user: "I'm about to generate the following files in `.claude/context/`. I'll show you each one before writing. Reply 'yes' to proceed with all, or review each individually."

### 4.1 Load Templates

Use the Read tool to load each template. Do not hardcode template content — always read from the plugin's reference files:

- Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-context/references/constitution-template.md`
- Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-context/references/trigger-table-template.md`
- Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-context/references/failure-modes-template.md`
- Read `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-context/references/subsystem-map-template.md`

### 4.2 Generate constitution.md

Fill the constitution template with analysis data and user answers. Substitution rules:

**Section 1 — Project Objectives**: Use `user_purpose`. Write concise bullet points for Purpose, Users, and Key outcomes.

**Section 2 — Technology Stack**: Populate from `project_type`, `package_manager`, and `language_files`. Detect framework from dependencies or directory names (e.g., presence of `next.config.*` → Next.js, `go.mod` with `gin` → Gin, `Cargo.toml` with `actix` → Actix). Leave unknown rows blank rather than guessing.

**Section 3 — Conventions & Standards**:
- For **Mature/Stable** maturity: infer from detected patterns (e.g., file extension mix suggests TypeScript vs JavaScript, presence of `.eslintrc` suggests ESLint).
- For **Greenfield**: write "TBD — establish and document here."
- Always include: naming, imports (if detectable), error handling (if detectable), code style (if config files found).

**Section 4 — Build & Run Commands**: Use `build_commands` from analysis. For any null command, write the placeholder text from the template but add a comment: `# Not detected — update when established`. Use the detected `package_manager` for the `install` command format.

**Section 5 — Architectural Summary**: Write 3-5 sentences describing the major layers based on the directory structure. Reference the subsystem map for details. For **Greenfield**, write a placeholder paragraph.

**Section 6 — Operational Checklists**: Fill `{test_command}`, `{lint_command}`, `{typecheck_command}` from detected build commands. For the "When adding a new {component type}" checklist, infer the component type from the project (e.g., "API endpoint" for backend, "React component" for frontend, "handler" for CLI tools).

**Section 7 — Known Failure Modes**: Write the top 3 based on project type (see failure-mode seeds below). Add a link to `failure-modes.md`.

**Section 8 — Trigger Table Reference**: Summarize 3-4 key routing rules from the trigger tables you will generate. Add a link to `trigger-tables.md`.

**Sections 9 and 10**: Copy directly from the template — do not modify the Codification Protocol or Maintenance Schedule sections.

**Dates**: Replace `{date}` placeholders with today's date in YYYY-MM-DD format.

**Failure mode seeds by project type** (for Section 7):

| Project Type | Seed Failure Modes |
|---|---|
| `nodejs` (Bun) | "Stale `node_modules` after branch switch → type errors"; "Missing `.env` variables → silent undefined failures"; "Editing generated files directly → changes overwritten on next codegen" |
| `nodejs` (npm/yarn/pnpm) | "Stale `node_modules` → dependency resolution errors"; "Missing `.env` → runtime failures"; "Skipping `npm install` after `package.json` changes" |
| `go` | "Missing `go generate` before build → stale generated code"; "Import cycle from new package → build failure"; "Forgetting `go mod tidy` after adding dependency" |
| `python` | "Virtual environment not activated → wrong interpreter"; "Missing `PYTHONPATH` for relative imports → ModuleNotFoundError"; "Stale `.pyc` cache after refactor" |
| `rust` | "Missing `cargo build` before running integration tests"; "Feature flags not set → compilation failure"; "Outdated `Cargo.lock` after manual `Cargo.toml` edit" |
| `java` | "Stale compiled classes after rename → class not found at runtime"; "Missing environment variables in test configuration"; "Dependency version conflict in transitive closure" |
| `ruby` | "Gemfile.lock mismatch → bundler version conflict"; "Missing database migration after branch switch"; "Environment-specific config not set" |
| `unknown` | "Missing required environment variables → runtime failure"; "Stale build artifacts → behavior mismatch"; "Dependency version drift between environments" |

### 4.3 Generate trigger-tables.md

Fill the trigger table template. Rules:

**File Pattern Routing table**: Auto-populate based on detected directories. For each directory found in `directory_structure`, create a row. Use these mappings as a starting point:

| Detected Directory Pattern | Keywords | Agent/Skill Suggestion |
|---|---|---|
| `api/`, `routes/`, `handlers/`, `endpoints/` | endpoint, route, handler, middleware | `api-specialist` or first detected agent |
| `db/`, `database/`, `migrations/`, `schema/` | schema, migration, query, seed | `db-specialist` |
| `frontend/`, `components/`, `ui/`, `pages/`, `views/`, `app/` (Next.js) | component, render, UI, layout | `frontend-specialist` |
| `test/`, `tests/`, `spec/`, `specs/`, `__tests__/` | test, spec, mock, fixture, assert | `test-specialist` |
| `*.config.*`, `.env*`, `config/`, `infra/`, `.github/` | config, environment, deploy, CI | `infra-specialist` |
| `docs/`, `*.md` files | documentation, readme, guide | `docs-specialist` |
| `cmd/`, `cli/`, `bin/` | command, flag, argument, CLI | `cli-specialist` |
| `pkg/`, `lib/`, `shared/`, `common/`, `utils/` | utility, helper, shared | general agent |

If the user named specific routing domains in Question 3, ensure those are in the table. If existing agents were found in `.claude/agents/`, use their actual names instead of placeholder names like `api-specialist`.

**Keyword Routing table**: Use the template's default rows. Adjust `specs/` references to match your actual project context (e.g., if no auth system is detectable, replace the auth row with something relevant to the project).

**Subsystem Routing table**: Populate one row per domain the user identified in Question 3. Use `user_routing_domains` to determine which subsystems get dedicated spec documents.

### 4.4 Generate failure-modes.md

Fill the failure modes template using the project-type seeds from Section 4.2. Distribution:

- **Critical Failures**: 1 entry — the most dangerous failure for this project type (e.g., data loss, auth bypass, corrupted state)
- **Build & Compile Failures**: 1-2 entries from seeds above
- **Runtime Failures**: 1-2 entries from seeds above
- **Test Failures**: 1 entry (generic: snapshot/fixture mismatch or test DB not running)
- **AI Agent-Specific Failures**: 1 entry — always include "Agent edits generated file directly" if codegen is detected, otherwise "Agent uses wrong package manager" if the package manager differs from the ecosystem default

Leave the "Archived Failures" section empty — it will fill over time.

### 4.5 Generate subsystem-map.md

Fill the subsystem map template using `directory_structure` from the analysis:

**Subsystem Overview (tree diagram)**: Render a text tree of the top-level directories. Mark directories with high `commit_count` in `git_hotspots` with `← HOT` comments.

**Detailed Subsystem Mapping table**: One row per top-level directory. Infer a human-readable subsystem name from the directory name (e.g., `src/api` → "API Layer", `cmd/` → "CLI Commands", `internal/` → "Internal Packages"). Leave `Spec Document` as `specs/{name}.md` (the file will not exist yet — that is correct).

**Subsystem Boundaries**: Add a named section for each domain the user identified in Question 3. For other directories, add minimal sections. For **Greenfield** projects, write placeholder text.

**Hot Areas table**: Populate from `git_hotspots`. If the project is not a git repo or has no history, write one placeholder row with "No git history available."

### 4.6 Create specs/ directory

Create the `specs/` directory and write a README explaining its purpose:

```bash
mkdir -p .claude/context/specs
```

Write `.claude/context/specs/README.md` with this content:

```markdown
# Subsystem Specs

This directory contains on-demand subsystem documentation. Files are loaded by the AI agent
only when entering the relevant subsystem — keeping the always-loaded context lean.

## Conventions

- One file per logical subsystem: `{subsystem-name}.md`
- Created when the subsystem is sufficiently complex to need documentation
- Referenced from `trigger-tables.md` and `subsystem-map.md`
- Updated using the `/codify-knowledge` skill when new patterns emerge

## Current Specs

(empty — add spec documents as subsystems mature)
```

### 4.7 Write .last-session-check

Get the current git SHA or write "none":

```bash
git rev-parse HEAD 2>/dev/null || echo "none"
```

Write the result to `.claude/context/.last-session-check`.

---

## Section 5: Human Review Before Writing

Before using the Bash or Write tools to create any file, present all generated content to the user:

```
I've prepared the following context infrastructure. Please review before I write:

--- .claude/context/constitution.md ---
[full content]

--- .claude/context/trigger-tables.md ---
[full content]

--- .claude/context/failure-modes.md ---
[full content]

--- .claude/context/subsystem-map.md ---
[full content]

--- .claude/context/specs/README.md ---
[content]

--- .claude/context/.last-session-check ---
[git SHA or "none"]

Proceed with writing all files? (yes / no / show me [filename] again)
```

If the user says no or requests changes, incorporate feedback and re-present before writing.

Once confirmed, create the directory and write all files:

```bash
mkdir -p .claude/context/specs
```

Use the Write tool for each `.md` file and `.last-session-check`. Do not use Bash redirection to write file content — use the Write tool to ensure content is written exactly as generated.

---

## Section 6: CLAUDE.md Integration

After writing the context files, append the context infrastructure reference block to the project's CLAUDE.md.

**Find the right CLAUDE.md:**
- If `CLAUDE.md` exists in the project root, append to it.
- If `.claude/CLAUDE.md` exists, append to it.
- If neither exists, create `CLAUDE.md` in the project root.

**Do not overwrite existing CLAUDE.md content.** Use the Edit tool to append after the last line.

Append exactly this block (substitute the actual current date for `[DATE]`):

```markdown

## Context Infrastructure

This project uses codified context infrastructure. Key files:
- `.claude/context/constitution.md` — Core project conventions (loaded every session)
- `.claude/context/trigger-tables.md` — File pattern → agent/skill routing
- `.claude/context/failure-modes.md` — Known failure symptom → cause → fix mappings
- `.claude/context/subsystem-map.md` — Directory → subsystem ownership
- `.claude/context/specs/` — On-demand subsystem documentation

> Run `/audit-staleness` to check for context drift. Run `/codify-knowledge` to capture session insights.

<!-- codified-context bootstrap: [DATE] -->
```

The HTML comment at the end serves as a staleness anchor — the `/audit-staleness` skill uses it to track when the infrastructure was last bootstrapped.

---

## Section 7: Verification

After all files are written, run verification:

```bash
ls -lh .claude/context/ .claude/context/specs/
```

Report results to the user in this format:

```
Context infrastructure created successfully.

Files written:
  .claude/context/constitution.md        [size]
  .claude/context/trigger-tables.md      [size]
  .claude/context/failure-modes.md       [size]
  .claude/context/subsystem-map.md       [size]
  .claude/context/specs/README.md        [size]
  .claude/context/.last-session-check    [size]

CLAUDE.md updated: [path to the file updated]

Next steps:
1. Review constitution.md — especially §3 (Conventions) and §4 (Build Commands).
   Correct any sections marked TBD or "not detected".
2. Review trigger-tables.md — confirm agent/skill names match your .claude/agents/ setup.
3. Start working — the Codification Protocol in constitution.md §9 will prompt you
   to capture knowledge as you discover it.
4. Run /audit-staleness periodically to detect context drift.
5. Run /codify-knowledge after sessions where you discovered new patterns or failure modes.
```

---

## Implementation Notes

**Tool usage rules for this skill:**

- Use the **Bash tool** to run `analyze-repo.sh` and create directories (`mkdir -p`).
- Use the **Read tool** to load templates from `${CLAUDE_PLUGIN_ROOT}/skills/bootstrap-context/references/`. Never inline template content.
- Use the **Write tool** to write generated files. Never use Bash heredocs or redirection for file content.
- Use the **Edit tool** to append to an existing CLAUDE.md.
- Use the **AskUserQuestion tool** for the three interactive questions in Section 3.

**Path resolution:**

All output files are written under `.claude/context/` relative to the current working directory (the project root). Use absolute paths when writing: `$(pwd)/.claude/context/constitution.md`. Confirm `pwd` before writing if there is any ambiguity.

**Idempotency:**

If any individual file already exists but `.claude/context/` was not fully bootstrapped (partial state), check each file and skip files that already exist unless the user explicitly requested regeneration.

**Error handling:**

If `analyze-repo.sh` exits non-zero, capture stderr, report the error to the user, and ask whether to continue with manual analysis or abort. Do not silently fall back.

**Project type: unknown:**

If `project_type` is `"unknown"` after analysis, ask the user to identify the primary language/framework before generating files. Use their answer to select the correct failure mode seeds and build command placeholders.
