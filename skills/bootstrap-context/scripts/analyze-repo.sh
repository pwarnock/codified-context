#!/usr/bin/env bash
# analyze-repo.sh
#
# Auto-analyzes a repository to bootstrap Claude Code context infrastructure.
# Detects project type, package manager, build/test/lint commands, directory
# structure, git hotspots, existing Claude config, language file counts,
# dependency count, test presence, and CI presence.
#
# Usage: analyze-repo.sh [project-root]
#   project-root: path to the repository root (defaults to current directory)
#
# Output: structured JSON to stdout
# Dependencies: jq (required), git (optional — hotspots skipped if absent)

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve project root
# ---------------------------------------------------------------------------
PROJECT_ROOT="${1:-$(pwd)}"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

cd "$PROJECT_ROOT"

# ---------------------------------------------------------------------------
# Helper: safe jq string (escape for use inside a jq --arg)
# ---------------------------------------------------------------------------
jq_str() {
  printf '%s' "$1" | jq -Rs '.'
}

# ---------------------------------------------------------------------------
# 1. Detect project type and package manager
# ---------------------------------------------------------------------------
project_type="unknown"
package_manager="unknown"

detect_project_type() {
  # Node.js / Bun / JavaScript / TypeScript
  if [[ -f "package.json" ]]; then
    project_type="nodejs"
    if [[ -f "bun.lock" || -f "bun.lockb" ]]; then
      package_manager="bun"
    elif [[ -f "pnpm-lock.yaml" ]]; then
      package_manager="pnpm"
    elif [[ -f "yarn.lock" ]]; then
      package_manager="yarn"
    elif [[ -f "package-lock.json" ]]; then
      package_manager="npm"
    else
      # Check if bun is installed and infer from usage
      if command -v bun &>/dev/null; then
        package_manager="bun"
      else
        package_manager="npm"
      fi
    fi
    return
  fi

  # Go
  if [[ -f "go.mod" ]]; then
    project_type="go"
    package_manager="go"
    return
  fi

  # Python
  if [[ -f "pyproject.toml" || -f "setup.py" || -f "setup.cfg" || -f "requirements.txt" ]]; then
    project_type="python"
    if [[ -f "uv.lock" ]]; then
      package_manager="uv"
    elif [[ -f "poetry.lock" ]]; then
      package_manager="poetry"
    elif [[ -f "Pipfile.lock" || -f "Pipfile" ]]; then
      package_manager="pipenv"
    elif command -v pip &>/dev/null; then
      package_manager="pip"
    else
      package_manager="pip"
    fi
    return
  fi

  # Rust
  if [[ -f "Cargo.toml" ]]; then
    project_type="rust"
    package_manager="cargo"
    return
  fi

  # C# / .NET
  if compgen -G "*.csproj" &>/dev/null || compgen -G "*.sln" &>/dev/null; then
    project_type="csharp"
    package_manager="dotnet"
    return
  fi

  # Java / Kotlin (Maven)
  if [[ -f "pom.xml" ]]; then
    project_type="java"
    package_manager="maven"
    return
  fi

  # Java / Kotlin (Gradle)
  if [[ -f "build.gradle" || -f "build.gradle.kts" ]]; then
    project_type="java"
    package_manager="gradle"
    return
  fi

  # Ruby
  if [[ -f "Gemfile" ]]; then
    project_type="ruby"
    package_manager="bundler"
    return
  fi

  # PHP
  if [[ -f "composer.json" ]]; then
    project_type="php"
    package_manager="composer"
    return
  fi

  # Swift
  if [[ -f "Package.swift" ]]; then
    project_type="swift"
    package_manager="swift"
    return
  fi
}

detect_project_type

# ---------------------------------------------------------------------------
# 2. Extract build/test/lint commands
# ---------------------------------------------------------------------------
cmd_install="null"
cmd_dev="null"
cmd_build="null"
cmd_test="null"
cmd_lint="null"
cmd_typecheck="null"

extract_nodejs_commands() {
  if [[ ! -f "package.json" ]]; then return; fi

  local pm="$package_manager"
  local run_prefix
  case "$pm" in
    bun)   run_prefix="bun run" ;;
    pnpm)  run_prefix="pnpm run" ;;
    yarn)  run_prefix="yarn" ;;
    *)     run_prefix="npm run" ;;
  esac

  local install_cmd
  case "$pm" in
    bun)   install_cmd="bun install" ;;
    pnpm)  install_cmd="pnpm install" ;;
    yarn)  install_cmd="yarn install" ;;
    *)     install_cmd="npm install" ;;
  esac
  cmd_install="\"$install_cmd\""

  # Extract script names from package.json
  local scripts
  scripts="$(jq -r '.scripts // {} | keys[]' package.json 2>/dev/null || true)"

  for script in $scripts; do
    case "$script" in
      dev|start:dev|develop)
        [[ "$cmd_dev" == "null" ]] && cmd_dev="\"$run_prefix $script\""
        ;;
      build|compile|bundle)
        [[ "$cmd_build" == "null" ]] && cmd_build="\"$run_prefix $script\""
        ;;
      test|test:unit|test:all)
        [[ "$cmd_test" == "null" ]] && cmd_test="\"$run_prefix $script\""
        ;;
      lint|lint:check|eslint)
        [[ "$cmd_lint" == "null" ]] && cmd_lint="\"$run_prefix $script\""
        ;;
      typecheck|type-check|tsc|types)
        [[ "$cmd_typecheck" == "null" ]] && cmd_typecheck="\"$run_prefix $script\""
        ;;
    esac
  done
}

extract_makefile_commands() {
  if [[ ! -f "Makefile" && ! -f "makefile" ]]; then return; fi
  local mf="Makefile"
  [[ -f "makefile" ]] && mf="makefile"

  local targets
  targets="$(grep -E '^[a-zA-Z0-9_-]+:' "$mf" 2>/dev/null | sed 's/:.*//' || true)"

  for target in $targets; do
    case "$target" in
      install|deps|setup)
        [[ "$cmd_install" == "null" ]] && cmd_install="\"make $target\""
        ;;
      dev|serve|run)
        [[ "$cmd_dev" == "null" ]] && cmd_dev="\"make $target\""
        ;;
      build|compile|bundle)
        [[ "$cmd_build" == "null" ]] && cmd_build="\"make $target\""
        ;;
      test|tests|check)
        [[ "$cmd_test" == "null" ]] && cmd_test="\"make $target\""
        ;;
      lint|vet|fmt-check|format-check)
        [[ "$cmd_lint" == "null" ]] && cmd_lint="\"make $target\""
        ;;
    esac
  done
}

extract_go_commands() {
  if [[ "$project_type" != "go" ]]; then return; fi
  [[ "$cmd_install" == "null" ]] && cmd_install="\"go mod download\""
  [[ "$cmd_build" == "null" ]] && cmd_build="\"go build ./...\""
  [[ "$cmd_test" == "null" ]]  && cmd_test="\"go test ./...\""
  # golangci-lint if available
  if command -v golangci-lint &>/dev/null; then
    [[ "$cmd_lint" == "null" ]] && cmd_lint="\"golangci-lint run\""
  fi
}

extract_python_commands() {
  if [[ "$project_type" != "python" ]]; then return; fi

  local pm="$package_manager"

  case "$pm" in
    uv)
      [[ "$cmd_install" == "null" ]] && cmd_install="\"uv sync\""
      [[ "$cmd_test" == "null" ]]    && cmd_test="\"uv run pytest\""
      [[ "$cmd_lint" == "null" ]]    && cmd_lint="\"uv run ruff check .\""
      ;;
    poetry)
      [[ "$cmd_install" == "null" ]] && cmd_install="\"poetry install\""
      [[ "$cmd_test" == "null" ]]    && cmd_test="\"poetry run pytest\""
      [[ "$cmd_lint" == "null" ]]    && cmd_lint="\"poetry run flake8 .\""
      ;;
    *)
      if [[ "$cmd_install" == "null" ]]; then
        if [[ -f "requirements.txt" ]]; then
          cmd_install="\"pip install -r requirements.txt\""
        elif [[ -f "pyproject.toml" ]]; then
          cmd_install="\"pip install -e .\""
        elif [[ -f "setup.py" ]]; then
          cmd_install="\"pip install -e .\""
        fi
      fi
      [[ "$cmd_test" == "null" ]]    && cmd_test="\"pytest\""
      [[ "$cmd_lint" == "null" ]]    && cmd_lint="\"flake8 .\""
      ;;
  esac

  # Check pyproject.toml for tool.taskipy, tool.scripts, etc.
  if [[ -f "pyproject.toml" ]] && command -v python3 &>/dev/null; then
    local build_sys
    build_sys="$(python3 -c "
import sys
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        sys.exit(0)
with open('pyproject.toml', 'rb') as f:
    d = tomllib.load(f)
scripts = d.get('tool', {}).get('taskipy', {}).get('tasks', {})
for k, v in scripts.items():
    print(f'{k}={v}')
" 2>/dev/null || true)"
    for entry in $build_sys; do
      local key="${entry%%=*}"
      local val="${entry#*=}"
      case "$key" in
        test)   [[ "$cmd_test" == "null" ]] && cmd_test="\"task $key\"" ;;
        lint)   [[ "$cmd_lint" == "null" ]] && cmd_lint="\"task $key\"" ;;
        build)  [[ "$cmd_build" == "null" ]] && cmd_build="\"task $key\"" ;;
      esac
    done
  fi
}

extract_rust_commands() {
  if [[ "$project_type" != "rust" ]]; then return; fi
  [[ "$cmd_install" == "null" ]] && cmd_install="\"cargo fetch\""
  [[ "$cmd_build" == "null" ]]   && cmd_build="\"cargo build\""
  [[ "$cmd_test" == "null" ]]    && cmd_test="\"cargo test\""
  [[ "$cmd_lint" == "null" ]]    && cmd_lint="\"cargo clippy\""
}

extract_java_commands() {
  if [[ "$project_type" != "java" ]]; then return; fi
  local pm="$package_manager"
  case "$pm" in
    maven)
      [[ "$cmd_build" == "null" ]] && cmd_build="\"mvn package\""
      [[ "$cmd_test" == "null" ]]  && cmd_test="\"mvn test\""
      [[ "$cmd_lint" == "null" ]]  && cmd_lint="\"mvn verify\""
      ;;
    gradle)
      [[ "$cmd_build" == "null" ]] && cmd_build="\"./gradlew build\""
      [[ "$cmd_test" == "null" ]]  && cmd_test="\"./gradlew test\""
      [[ "$cmd_lint" == "null" ]]  && cmd_lint="\"./gradlew check\""
      ;;
  esac
}

extract_ruby_commands() {
  if [[ "$project_type" != "ruby" ]]; then return; fi
  [[ "$cmd_install" == "null" ]] && cmd_install="\"bundle install\""
  [[ "$cmd_test" == "null" ]]    && cmd_test="\"bundle exec rspec\""
  [[ "$cmd_lint" == "null" ]]    && cmd_lint="\"bundle exec rubocop\""
}

extract_dotnet_commands() {
  if [[ "$project_type" != "csharp" ]]; then return; fi
  [[ "$cmd_build" == "null" ]] && cmd_build="\"dotnet build\""
  [[ "$cmd_test" == "null" ]]  && cmd_test="\"dotnet test\""
  [[ "$cmd_lint" == "null" ]]  && cmd_lint="\"dotnet format --verify-no-changes\""
}

# Run extractors in priority order
extract_nodejs_commands
extract_makefile_commands
extract_go_commands
extract_python_commands
extract_rust_commands
extract_java_commands
extract_ruby_commands
extract_dotnet_commands

# ---------------------------------------------------------------------------
# 3. Map top-level directory structure
# ---------------------------------------------------------------------------
build_directory_structure() {
  local entries=()
  while IFS= read -r dir; do
    # Count files (non-recursively going deep — just one level inside)
    local count
    count="$(find "$dir" -maxdepth 3 -type f 2>/dev/null | wc -l)"
    entries+=("{\"path\": $(jq_str "$dir"), \"file_count\": $count}")
  done < <(find . -maxdepth 1 -mindepth 1 -type d \
    ! -name ".git" \
    ! -name "node_modules" \
    ! -name ".cache" \
    ! -name "vendor" \
    ! -name "__pycache__" \
    ! -name ".venv" \
    ! -name "venv" \
    ! -name "dist" \
    ! -name ".next" \
    ! -name "target" \
    ! -name ".build" \
    | sed 's|^\./||' | sort)

  local json_array="["
  local first=true
  for entry in "${entries[@]}"; do
    if $first; then
      json_array+="$entry"
      first=false
    else
      json_array+=", $entry"
    fi
  done
  json_array+="]"
  printf '%s' "$json_array"
}

# ---------------------------------------------------------------------------
# 4. Scan git log for hotspots (last 30 days)
# ---------------------------------------------------------------------------
build_git_hotspots() {
  if ! command -v git &>/dev/null; then
    printf '[]'
    return
  fi

  if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    printf '[]'
    return
  fi

  # Get files changed in last 30 days, extract top-level dirs, count commits
  local since_date
  since_date="$(date -d '30 days ago' '+%Y-%m-%d' 2>/dev/null || date -v-30d '+%Y-%m-%d' 2>/dev/null || true)"

  if [[ -z "$since_date" ]]; then
    printf '[]'
    return
  fi

  local raw
  raw="$(git log --since="$since_date" --name-only --pretty=format: 2>/dev/null \
    | grep -v '^$' \
    | sed 's|/.*||' \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -10 \
    || true)"

  if [[ -z "$raw" ]]; then
    printf '[]'
    return
  fi

  local entries=()
  while IFS= read -r line; do
    local count path_name
    count="$(echo "$line" | awk '{print $1}')"
    path_name="$(echo "$line" | awk '{print $2}')"
    [[ -n "$path_name" ]] && entries+=("{\"path\": $(jq_str "$path_name"), \"commit_count\": $count}")
  done <<< "$raw"

  local json_array="["
  local first=true
  for entry in "${entries[@]}"; do
    if $first; then
      json_array+="$entry"
      first=false
    else
      json_array+=", $entry"
    fi
  done
  json_array+="]"
  printf '%s' "$json_array"
}

# ---------------------------------------------------------------------------
# 5. Detect existing Claude Code config
# ---------------------------------------------------------------------------
has_claude_md=false
has_settings=false
has_agents=false
has_skills=false

[[ -f "CLAUDE.md" || -f ".claude/CLAUDE.md" ]] && has_claude_md=true
[[ -f ".claude/settings.json" ]]  && has_settings=true
[[ -d ".claude/agents" ]]         && has_agents=true
[[ -d ".claude/skills" ]]         && has_skills=true

# ---------------------------------------------------------------------------
# 6. Count files by extension (top 10, excluding common noise)
# ---------------------------------------------------------------------------
build_language_files() {
  local raw
  raw="$(find . -maxdepth 4 -type f \
    ! -path './.git/*' \
    ! -path './node_modules/*' \
    ! -path './vendor/*' \
    ! -path './.venv/*' \
    ! -path './venv/*' \
    ! -path './target/*' \
    ! -path './.next/*' \
    ! -path './dist/*' \
    ! -path './__pycache__/*' \
    2>/dev/null \
    | sed 's/.*\.//' \
    | grep -v '/' \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -10 \
    || true)"

  if [[ -z "$raw" ]]; then
    printf '{}'
    return
  fi

  local pairs=()
  while IFS= read -r line; do
    local count ext
    count="$(echo "$line" | awk '{print $1}')"
    ext="$(echo "$line" | awk '{print $2}')"
    [[ -n "$ext" ]] && pairs+=("$(jq_str "$ext"): $count")
  done <<< "$raw"

  local json_obj="{"
  local first=true
  for pair in "${pairs[@]}"; do
    if $first; then
      json_obj+="$pair"
      first=false
    else
      json_obj+=", $pair"
    fi
  done
  json_obj+="}"
  printf '%s' "$json_obj"
}

# ---------------------------------------------------------------------------
# 7. Count direct dependencies
# ---------------------------------------------------------------------------

# Count go.mod dependencies by parsing require blocks line by line
_count_gomod_deps() {
  local count=0
  local in_block=false
  while IFS= read -r gomod_line; do
    # Detect start of multi-line require block
    if [[ "$gomod_line" == require\ \(* ]]; then
      in_block=true
      continue
    fi
    # Detect end of block
    if $in_block && [[ "$gomod_line" == ")" ]]; then
      in_block=false
      continue
    fi
    # Inside a block — non-empty non-comment lines are deps
    if $in_block; then
      local trimmed="${gomod_line#"${gomod_line%%[![:space:]]*}"}"
      if [[ -n "$trimmed" && "$trimmed" != //* ]]; then
        count=$((count + 1))
      fi
      continue
    fi
    # Single-line require (not a block opener)
    if [[ "$gomod_line" == require\ * && "$gomod_line" != *"("* ]]; then
      count=$((count + 1))
    fi
  done < go.mod
  printf '%d' "$count"
}

# Count Cargo.toml [dependencies] entries
_count_cargo_deps() {
  local count=0
  local in_deps=false
  while IFS= read -r cargo_line; do
    if [[ "$cargo_line" == '[dependencies]' ]]; then
      in_deps=true
      continue
    fi
    # Any other section header ends the block
    if [[ "$cargo_line" == '['* ]]; then
      in_deps=false
      continue
    fi
    if $in_deps; then
      # Lines starting with a letter or underscore are dependency entries
      local first_char="${cargo_line:0:1}"
      if [[ "$first_char" =~ [a-zA-Z_] ]]; then
        count=$((count + 1))
      fi
    fi
  done < Cargo.toml
  printf '%d' "$count"
}

# Count pyproject.toml [project.dependencies] using python3
_count_pyproject_deps() {
  python3 - <<'PYEOF' 2>/dev/null || printf '0'
import sys
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print(0)
        sys.exit(0)
with open('pyproject.toml', 'rb') as f:
    d = tomllib.load(f)
deps = d.get('project', {}).get('dependencies', [])
print(len(deps))
PYEOF
}

count_dependencies() {
  local count=0

  if [[ -f "package.json" ]]; then
    local deps dev_deps
    deps="$(jq '.dependencies // {} | length' package.json 2>/dev/null || printf '0')"
    dev_deps="$(jq '.devDependencies // {} | length' package.json 2>/dev/null || printf '0')"
    count=$((deps + dev_deps))

  elif [[ -f "go.mod" ]]; then
    count="$(_count_gomod_deps)"

  elif [[ -f "pyproject.toml" ]] && command -v python3 &>/dev/null; then
    count="$(_count_pyproject_deps)"

  elif [[ -f "requirements.txt" ]]; then
    count="$(grep -cv '^\s*#\|^\s*$' requirements.txt 2>/dev/null || printf '0')"

  elif [[ -f "Cargo.toml" ]]; then
    count="$(_count_cargo_deps)"

  elif [[ -f "Gemfile" ]]; then
    count="$(grep -c '^gem ' Gemfile 2>/dev/null || printf '0')"

  elif [[ -f "pom.xml" ]]; then
    count="$(grep -c '<dependency>' pom.xml 2>/dev/null || printf '0')"

  elif [[ -f "build.gradle" ]]; then
    count="$(grep -cE '^\s*(implementation|api|compile|testImplementation|runtimeOnly)' build.gradle 2>/dev/null || printf '0')"
  fi

  printf '%d' "$count"
}

# ---------------------------------------------------------------------------
# 8. Detect tests
# ---------------------------------------------------------------------------
detect_has_tests() {
  # Common test directories
  for dir in test tests spec specs __tests__ src/test src/tests src/__tests__ e2e; do
    if [[ -d "$dir" ]]; then
      printf 'true'
      return
    fi
  done

  # Language-specific test file patterns (search recursively, stop at first match)
  # Go: *_test.go, Python: test_*.py / *_test.py, Ruby: *_spec.rb,
  # Java: *Test.java, C#: *Tests.cs, Rust: tests/ or #[test] in src/
  if find . -maxdepth 4 -type f \( \
    -name "*_test.go" -o \
    -name "test_*.py" -o \
    -name "*_test.py" -o \
    -name "*_spec.rb" -o \
    -name "*Test.java" -o \
    -name "*Tests.cs" -o \
    -name "*.test.ts" -o \
    -name "*.test.tsx" -o \
    -name "*.test.js" -o \
    -name "*.test.jsx" -o \
    -name "*.spec.ts" -o \
    -name "*.spec.tsx" -o \
    -name "*.spec.js" \
  \) -not -path './node_modules/*' -not -path './.git/*' -not -path './vendor/*' \
    -print -quit 2>/dev/null | grep -q .; then
    printf 'true'
    return
  fi

  # Check for test framework in package.json
  if [[ -f "package.json" ]]; then
    if jq -e '.devDependencies | to_entries[] | select(.key | test("jest|vitest|mocha|jasmine|ava|tap|playwright|cypress")) | .key' package.json &>/dev/null 2>&1; then
      printf 'true'
      return
    fi
    if jq -e '.scripts | to_entries[] | select(.key == "test") | .value' package.json &>/dev/null 2>&1; then
      printf 'true'
      return
    fi
  fi

  # Check for pytest config
  if [[ -f "pytest.ini" || -f "conftest.py" || -f "tox.ini" ]]; then
    printf 'true'
    return
  fi

  printf 'false'
}

# ---------------------------------------------------------------------------
# 9. Detect CI
# ---------------------------------------------------------------------------
detect_has_ci() {
  if [[ -d ".github/workflows" ]] && compgen -G ".github/workflows/*.yml" &>/dev/null 2>&1; then
    printf 'true'
    return
  fi
  if [[ -d ".github/workflows" ]] && compgen -G ".github/workflows/*.yaml" &>/dev/null 2>&1; then
    printf 'true'
    return
  fi
  if [[ -f ".gitlab-ci.yml" || -f ".gitlab-ci.yaml" ]]; then
    printf 'true'
    return
  fi
  if [[ -f "Jenkinsfile" ]]; then
    printf 'true'
    return
  fi
  if [[ -f ".circleci/config.yml" || -f ".circleci/config.yaml" ]]; then
    printf 'true'
    return
  fi
  if [[ -f ".travis.yml" || -f ".travis.yaml" ]]; then
    printf 'true'
    return
  fi
  if [[ -f "azure-pipelines.yml" || -f "azure-pipelines.yaml" ]]; then
    printf 'true'
    return
  fi
  printf 'false'
}

# ---------------------------------------------------------------------------
# Assemble all data
# ---------------------------------------------------------------------------
dir_structure="$(build_directory_structure)"
git_hotspots="$(build_git_hotspots)"
language_files="$(build_language_files)"
deps_count="$(count_dependencies)"
has_tests="$(detect_has_tests)"
has_ci="$(detect_has_ci)"

# ---------------------------------------------------------------------------
# Output JSON
# ---------------------------------------------------------------------------
jq -n \
  --arg     project_type      "$project_type" \
  --arg     package_manager   "$package_manager" \
  --argjson cmd_install       "$cmd_install" \
  --argjson cmd_dev           "$cmd_dev" \
  --argjson cmd_build         "$cmd_build" \
  --argjson cmd_test          "$cmd_test" \
  --argjson cmd_lint          "$cmd_lint" \
  --argjson cmd_typecheck     "$cmd_typecheck" \
  --argjson dir_structure     "$dir_structure" \
  --argjson git_hotspots      "$git_hotspots" \
  --argjson has_claude_md     "$has_claude_md" \
  --argjson has_settings      "$has_settings" \
  --argjson has_agents        "$has_agents" \
  --argjson has_skills        "$has_skills" \
  --argjson language_files    "$language_files" \
  --argjson deps_count        "$deps_count" \
  --argjson has_tests         "$has_tests" \
  --argjson has_ci            "$has_ci" \
  '{
    project_type: $project_type,
    package_manager: $package_manager,
    build_commands: {
      install:   $cmd_install,
      dev:       $cmd_dev,
      build:     $cmd_build,
      test:      $cmd_test,
      lint:      $cmd_lint,
      typecheck: $cmd_typecheck
    },
    directory_structure: $dir_structure,
    git_hotspots: $git_hotspots,
    existing_claude_config: {
      claude_md: $has_claude_md,
      settings:  $has_settings,
      agents:    $has_agents,
      skills:    $has_skills
    },
    language_files:     $language_files,
    dependencies_count: $deps_count,
    has_tests:          $has_tests,
    has_ci:             $has_ci
  }'
