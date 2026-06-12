# ─────────────────────────────────────────────────
# .claude/hooks/block-sensitive-writes.sh
# ─────────────────────────────────────────────────

#!/bin/bash
# .claude/hooks/block-sensitive-writes.sh
# Blocks writes to secrets, migrations, and read-only directories.
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

if [[ "$TOOL" =~ ^(Write|Edit|MultiEdit)$ ]] && [[ -n "$FILE_PATH" ]]; then
  # Block secret file writes
  if echo "$FILE_PATH" | grep -qE '\.(env|key|pem|secret)$|\.env\.' ; then
    echo "Blocked: Do not write to secret files. Edit .env files manually." >&2
    exit 2
  fi

  # Block writes to docs/ (reference only, not authoritative)
  if echo "$FILE_PATH" | grep -q '^docs/'; then
    echo "Blocked: docs/ is reference-only. Source of truth is code + specs/. Update specs/ instead." >&2
    exit 2
  fi

  # Block direct migration file edits (must go through SQLAlchemy migration tooling)
  if echo "$FILE_PATH" | grep -q 'migrations/versions/'; then
    echo "Blocked: Do not edit migration files directly. Use alembic revision --autogenerate." >&2
    exit 2
  fi
fi

exit 0

