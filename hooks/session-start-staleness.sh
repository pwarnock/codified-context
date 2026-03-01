#!/usr/bin/env bash
set -euo pipefail

# Graceful error handling — never block a session
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CONTEXT_DIR="${PROJECT_DIR}/.claude/context"
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# Source shared utilities
source "${PLUGIN_ROOT}/lib/context-utils.sh" 2>/dev/null || true

# escape_for_json function (same pattern as superpowers)
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# Check if context infrastructure exists
if [ ! -d "$CONTEXT_DIR" ]; then
    message="This project doesn't have codified context infrastructure yet. Run /bootstrap-context to set it up."
    escaped=$(escape_for_json "$message")
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${escaped}"
  }
}
EOF
    exit 0
fi

# Check for staleness
last_sha_file="${CONTEXT_DIR}/.last-session-check"
warning=""

if [ -f "$last_sha_file" ] && command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
    last_sha=$(cat "$last_sha_file" 2>/dev/null || echo "none")
    current_sha=$(git rev-parse HEAD 2>/dev/null || echo "none")

    if [ "$last_sha" != "none" ] && [ "$current_sha" != "none" ] && [ "$last_sha" != "$current_sha" ]; then
        # Get changed files since last check
        changed_files=$(git diff --name-only "$last_sha" "$current_sha" 2>/dev/null || echo "")

        if [ -n "$changed_files" ]; then
            # Check for drift against subsystem map
            drift_report=$(check_subsystem_drift "$changed_files" "$CONTEXT_DIR" 2>/dev/null || echo "")

            if [ -n "$drift_report" ]; then
                commit_count=$(echo "$changed_files" | wc -l | tr -d ' ')
                warning="⚠️ **Context drift detected** — ${commit_count} files changed since last session.\n\n${drift_report}\n\nRun /audit-staleness for a detailed analysis, or review .claude/context/ docs if they need updating."
            fi
        fi

        # Update last-checked SHA
        echo "$current_sha" > "$last_sha_file" 2>/dev/null || true
    fi
fi

# Also check if constitution.md references files that no longer exist (quick spot check)
if [ -f "${CONTEXT_DIR}/constitution.md" ]; then
    # Quick staleness heuristic: check if constitution was modified more than 30 days ago
    if command -v find &>/dev/null; then
        stale_constitution=$(find "${CONTEXT_DIR}/constitution.md" -mtime +30 2>/dev/null || echo "")
        if [ -n "$stale_constitution" ] && [ -z "$warning" ]; then
            warning="📋 Constitution hasn't been updated in 30+ days. Consider running /audit-staleness to check for drift."
        fi
    fi
fi

if [ -n "$warning" ]; then
    escaped=$(escape_for_json "$warning")
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${escaped}"
  }
}
EOF
else
    # No issues, output minimal valid JSON
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ""
  }
}
EOF
fi

exit 0
