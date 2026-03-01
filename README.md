# codified-context

Three-tier persistent context infrastructure for AI coding agents. Based on ["Codified Context: Infrastructure for AI Agents in a Complex Codebase"](https://arxiv.org/abs/2602.20478) (Vasilopoulos, 2025).

## Problem

LLM coding agents lose context between sessions. They re-explain concepts, repeat debugging mistakes, and don't know which specialist to invoke for which files.

## Solution

A Claude Code plugin implementing the paper's three-tier infrastructure:

1. **Hot Memory (Constitution)** — Core conventions, architecture summary, and build commands loaded every session
2. **Routing Intelligence (Trigger Tables)** — File patterns and keywords mapped to the right agent, skill, or context document
3. **Cold Memory (Specs)** — On-demand subsystem documentation loaded only when needed

## Quick Start

### Install the plugin

```bash
claude plugin install codified-context
```

### Bootstrap your project

```
/bootstrap-context
```

This auto-analyzes your project (type, dependencies, structure, git hotspots), asks 3 questions, and generates:

```
.claude/context/
├── constitution.md       # Core conventions and architecture
├── trigger-tables.md     # File pattern → agent/skill routing
├── failure-modes.md      # Symptom → Cause → Fix mappings
├── subsystem-map.md      # Directory → subsystem ownership
├── .last-session-check   # Git SHA for staleness tracking
└── specs/                # On-demand subsystem documentation
```

### Use it

- **Automatic staleness detection**: Every session start checks if code changed without context updates
- **`/audit-staleness`**: Deep audit of context freshness with specific fix proposals
- **`/codify-knowledge`**: Capture debugging insights and decisions as durable context
- **`/review-context`**: Health check with coverage analysis and quality scores

## Commands

| Command | Purpose |
|---------|---------|
| `/bootstrap-context` | Initialize context infrastructure for a project |
| `/audit-staleness` | Check for drift between code and context docs |
| `/codify-knowledge` | Capture session knowledge into context documents |
| `/review-context` | Review context health with quality scoring |

## How It Works

### Session Start Hook

On every session start, a lightweight bash hook:
1. Compares the current git SHA against the last-checked SHA
2. Diffs changed files against the subsystem map
3. Injects a warning if subsystems changed without context updates

### Codification Loop

The constitution includes a "Codification Protocol" (§9) that instructs the AI to self-detect when knowledge should be captured:

- Explained something twice → write it down
- Debugging breakthrough → add to failure modes
- Architecture decision → document in specs
- Found a gotcha → add to conventions

### Trigger Table Routing

The `context-routing` skill teaches the AI to consult trigger tables when working with files:

- File pattern match → load the right spec, invoke the right agent
- Keyword detection → load relevant context documents
- Subsystem entry → load subsystem-specific documentation

## Standalone Skills

If you want the methodology without the full plugin (no hooks, no commands), three standalone skills are available:

| Skill | What it provides |
|-------|-----------------|
| `codified-context-patterns` | Three-tier framework overview + all templates |
| `codification-loop` | The "explained it twice, write it down" methodology |
| `context-health` | Coverage analysis rubrics and quality scoring |

Install these in `~/.claude/skills/` or via the skills marketplace.

## Plugin Structure

```
.
├── .claude-plugin/plugin.json     # Plugin manifest
├── commands/                      # 4 slash commands
├── agents/context-architect.md    # Subsystem analysis agent
├── skills/
│   ├── bootstrap-context/         # Project initialization wizard
│   ├── audit-staleness/           # Deep drift analysis
│   ├── codify-knowledge/          # Knowledge capture loop
│   ├── review-context/            # Health check and scoring
│   └── context-routing/           # Trigger table routing logic
├── hooks/                         # Session-start staleness hook
├── lib/context-utils.sh           # Shared bash utilities
└── standalone-skills/             # Methodology-only skills (no plugin required)
    ├── codified-context-patterns/
    ├── codification-loop/
    └── context-health/
```

## References

- [Codified Context: Infrastructure for AI Agents in a Complex Codebase](https://arxiv.org/abs/2602.20478) (Vasilopoulos, 2025)
- Evaluated across 283 development sessions on a 108K-line C# codebase
- Key finding: a basic constitution eliminates entire categories of recurring failures

## Related

- [superpowers](https://github.com/obra/superpowers) — Workflow discipline skills for Claude Code (TDD, debugging, code review). Pairs well with codified-context: superpowers provides the *how*, codified-context provides the *what to remember*.

## License

MIT
