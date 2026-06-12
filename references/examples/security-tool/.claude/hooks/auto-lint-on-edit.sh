# ─────────────────────────────────────────────────
# .claude/hooks/auto-lint-on-edit.sh
# ─────────────────────────────────────────────────

#!/bin/bash
# .claude/hooks/auto-lint-on-edit.sh
# Runs the appropriate linter after every file write.
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

if [[ "$TOOL" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ -n "$FILE_PATH" ]]; then
  if echo "$FILE_PATH" | grep -qE '\.(ts|tsx)$'; then
    cd "$(dirname "$FILE_PATH")" 2>/dev/null || true
    npx eslint "$FILE_PATH" --max-warnings=0 2>&1 || {
      echo "TypeScript lint errors in $FILE_PATH. Fix before proceeding." >&2
      exit 2
    }
  fi

  if echo "$FILE_PATH" | grep -qE '\.py$'; then
    ruff check "$FILE_PATH" 2>&1 || {
      echo "Python lint errors in $FILE_PATH. Fix before proceeding." >&2
      exit 2
    }
  fi
fi

exit 0
