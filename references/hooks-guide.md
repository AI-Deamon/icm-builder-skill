# Hooks Guide

## What hooks are

Hooks are deterministic scripts that fire at specific points in Claude Code's lifecycle.
Unlike CONTEXT.md instructions (which Claude interprets), hooks execute code.
They cannot hallucinate. They cannot "forget". They are not advisory.

**The fundamental distinction:**
- CONTEXT.md / AGENTS.md = advisory. Claude reads and interprets.
- Hooks = mandatory. The script runs. Exit 2 = blocked. No exceptions.

---

## Hook lifecycle events

| Event | When it fires | Use for |
|-------|--------------|---------|
| `PreToolUse` | Before Claude uses any tool | Blocking dangerous actions |
| `PostToolUse` | After Claude uses any tool | Running follow-up automation |
| `Stop` | When Claude is about to declare done | Verification gates |
| `Notification` | On important events | Alerts (Slack, email) |

---

## Hook input format

Hooks receive JSON on stdin. Always use `jq` to parse it.

```json
{
  "tool": "Write",
  "tool_input": {
    "file_path": "/path/to/file.py",
    "content": "..."
  }
}
```

For Bash tool calls:
```json
{
  "tool": "Bash",
  "tool_input": {
    "command": "rm -rf ./data"
  }
}
```

---

## Exit codes

| Exit code | Meaning |
|-----------|---------|
| 0 | Allow. Continue normally. |
| 2 | Block. Print stderr to Claude. Claude sees the message and cannot proceed. |
| Any other | Allow (treated as 0). |

The old `decision/reason` JSON return format is deprecated. Use exit codes only.

---

## Hook script template

```bash
#!/bin/bash
# .claude/hooks/[hook-name].sh
# Purpose: [one sentence describing what this hook enforces]
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

# [Blocking condition]
if [[ condition ]]; then
  echo "Blocked: [human-readable reason Claude will see]" >&2
  exit 2
fi

exit 0
```

Make every hook script executable: `chmod +x .claude/hooks/*.sh`

---

## settings.json — hook configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-sensitive-writes.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-dangerous-commands.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-lint.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/verify-before-stop.sh"
          }
        ]
      }
    ]
  }
}
```

The `matcher` field is a regex matched against the tool name. `"Write|Edit"` matches both.

---

## Common hook patterns for dev projects

### Block writes to secrets and sensitive files

```bash
#!/bin/bash
# .claude/hooks/block-sensitive-writes.sh
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

if [[ "$TOOL" =~ ^(Write|Edit|MultiEdit)$ ]]; then
  # Block writes to secrets
  if echo "$FILE_PATH" | grep -qE '\.(env|key|pem|p12|pfx|secret)$'; then
    echo "Blocked: Writing to secret files is not allowed. Edit manually." >&2
    exit 2
  fi
  # Block writes to migration files (must be done deliberately)
  if echo "$FILE_PATH" | grep -q 'migrations/'; then
    echo "Blocked: Migrations must be created via the migration tool, not direct edit." >&2
    exit 2
  fi
fi

exit 0
```

### Block dangerous bash commands

```bash
#!/bin/bash
# .claude/hooks/block-dangerous-commands.sh
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

if [[ "$TOOL" == "Bash" ]]; then
  # Block data-destroying commands
  if echo "$COMMAND" | grep -qE 'docker compose down --volumes|python run\.py down'; then
    echo "Blocked: This command destroys all database data. Run manually if intentional." >&2
    exit 2
  fi
  # Block force-push
  if echo "$COMMAND" | grep -q 'git push.*--force'; then
    echo "Blocked: Force push not allowed. Use --force-with-lease if necessary." >&2
    exit 2
  fi
fi

exit 0
```

### Auto-lint after file edits

```bash
#!/bin/bash
# .claude/hooks/auto-lint.sh
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

if [[ "$TOOL" =~ ^(Write|Edit|MultiEdit)$ ]]; then
  # Only lint supported file types
  if echo "$FILE_PATH" | grep -qE '\.(py|ts|tsx|js|jsx)$'; then
    echo "Auto-linting $FILE_PATH..."

    if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx)$'; then
      npx eslint "$FILE_PATH" --max-warnings=0 2>&1 || {
        echo "Lint errors in $FILE_PATH. Fix before proceeding." >&2
        exit 2
      }
    fi

    if echo "$FILE_PATH" | grep -qE '\.py$'; then
      ruff check "$FILE_PATH" 2>&1 || {
        echo "Lint errors in $FILE_PATH. Fix before proceeding." >&2
        exit 2
      }
    fi
  fi
fi

exit 0
```

### Verification gate before stop

```bash
#!/bin/bash
# .claude/hooks/verify-before-stop.sh
# Runs the project's test suite before Claude declares done.
# Edit this file to match your project's actual verification commands.
set -euo pipefail

echo "Running verification before completion..."

# Run tests — adjust to your test command
if ! [[ -f "package.json" ]] && ! [[ -f "pytest.ini" ]] && ! [[ -f "pyproject.toml" ]]; then
  echo "No test suite detected. Skipping verification." >&2
  exit 0
fi

# Frontend tests
if [[ -f "package.json" ]]; then
  npx vitest run 2>&1 || {
    echo "Frontend tests failed. Completion blocked." >&2
    exit 2
  }
fi

# Backend tests
if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]]; then
  pytest tests/ -q 2>&1 || {
    echo "Backend tests failed. Completion blocked." >&2
    exit 2
  }
fi

echo "Verification passed."
exit 0
```

---

## Hooks vs. CONTEXT.md — decision framework

| Situation | Hook | CONTEXT.md |
|-----------|------|------------|
| Never write to `.env` files | ✅ | ❌ |
| Always run linter after edits | ✅ | ❌ |
| Don't run `python run.py down` carelessly | ✅ | ❌ |
| Follow API naming conventions | ❌ | ✅ |
| Use camelCase for variables | ❌ | ✅ |
| Don't add unnecessary dependencies | ❌ | ✅ |
| Rebuild celery alongside backend | ❌ | ✅ (hard rule) |
| Never hardcode secrets | Both | Both |

**Rule of thumb:** If it's reversible and requires judgment → CONTEXT.md.
If it's irreversible or must-not-skip → Hook.

---

## Anti-patterns

| Anti-pattern | Fix |
|--------------|-----|
| Hook that prints message and exits 0 | Use exit 2 to actually block |
| Using deprecated `decision/reason` JSON | Use exit codes instead |
| Hook for every possible situation | Only hook truly mandatory, irreversible things |
| Hook script without `set -euo pipefail` | Add it — silent failures are worse than errors |
| Not making hook scripts executable | `chmod +x .claude/hooks/*.sh` |
| Hook that calls external services | Keep hooks fast and local — slow hooks block Claude |
| Verify-before-stop that always passes | Include a real test command that can actually fail |
