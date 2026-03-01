#!/usr/bin/env bash
# Shared utilities for codified-context plugin
# Sourced by hooks and scripts — not executed directly

# Parse subsystem-map.md and return directory patterns
# Usage: get_subsystem_patterns /path/to/.claude/context
get_subsystem_patterns() {
    local context_dir="$1"
    local map_file="${context_dir}/subsystem-map.md"

    if [ ! -f "$map_file" ]; then
        return 0
    fi

    # Extract directory patterns from the "Detailed Subsystem Mapping" table
    # Format: | `src/path/**` | Name | Description | ...
    grep -oP '`[^`]+`' "$map_file" | grep -E '/' | sed 's/`//g' | sort -u
}

# Check which subsystems have drift based on changed files
# Usage: check_subsystem_drift "file1\nfile2\nfile3" /path/to/.claude/context
check_subsystem_drift() {
    local changed_files="$1"
    local context_dir="$2"
    local map_file="${context_dir}/subsystem-map.md"

    if [ ! -f "$map_file" ]; then
        return 0
    fi

    local drift_report=""
    local affected_subsystems=""

    # Read subsystem boundaries from the map
    # Look for lines like: | `src/api/**` | API | ...
    while IFS='|' read -r _ pattern name _rest; do
        # Clean up the fields
        pattern=$(echo "$pattern" | sed 's/`//g' | xargs 2>/dev/null || echo "$pattern")
        name=$(echo "$name" | xargs 2>/dev/null || echo "$name")

        [ -z "$pattern" ] || [ -z "$name" ] && continue

        # Convert glob to grep pattern (basic conversion)
        local grep_pattern
        grep_pattern=$(echo "$pattern" | sed 's/\*\*/.\*/g' | sed 's/\*/[^\/]*/g')

        # Check if any changed files match this subsystem
        local matches
        matches=$(echo "$changed_files" | grep -c -E "$grep_pattern" 2>/dev/null || echo "0")

        if [ "$matches" -gt 0 ]; then
            affected_subsystems="${affected_subsystems}- **${name}** (${pattern}): ${matches} file(s) changed\n"
        fi
    done < <(grep -E '^\|.*`.*`.*\|' "$map_file" | grep -v '^\| Directory' | grep -v '^\|---')

    if [ -n "$affected_subsystems" ]; then
        echo "Affected subsystems:\n${affected_subsystems}"
    fi
}

# Get the current git SHA, returns "none" if not in a git repo
get_current_sha() {
    git rev-parse HEAD 2>/dev/null || echo "none"
}

# Check if a context file exists and is non-empty
context_file_exists() {
    local context_dir="$1"
    local filename="$2"
    [ -f "${context_dir}/${filename}" ] && [ -s "${context_dir}/${filename}" ]
}

# List all spec files in the specs/ directory
list_specs() {
    local context_dir="$1"
    local specs_dir="${context_dir}/specs"

    if [ -d "$specs_dir" ]; then
        find "$specs_dir" -name "*.md" -type f | sort
    fi
}

# Count context infrastructure completeness (0-100)
context_completeness_score() {
    local context_dir="$1"
    local score=0
    local total=5

    context_file_exists "$context_dir" "constitution.md" && score=$((score + 1))
    context_file_exists "$context_dir" "trigger-tables.md" && score=$((score + 1))
    context_file_exists "$context_dir" "failure-modes.md" && score=$((score + 1))
    context_file_exists "$context_dir" "subsystem-map.md" && score=$((score + 1))
    [ -d "${context_dir}/specs" ] && [ "$(find "${context_dir}/specs" -name "*.md" -type f 2>/dev/null | wc -l)" -gt 0 ] && score=$((score + 1))

    echo $(( (score * 100) / total ))
}
