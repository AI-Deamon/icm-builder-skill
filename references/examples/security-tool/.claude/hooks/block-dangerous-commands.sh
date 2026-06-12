# ─────────────────────────────────────────────────
# .claude/hooks/block-dangerous-commands.sh
# ─────────────────────────────────────────────────

#!/bin/bash
# .claude/hooks/block-dangerous-commands.sh
# Blocks commands that destroy data or violate security policy.
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

if [[ "$TOOL" == "Bash" ]]; then
  # Block data-destroying docker command
  if echo "$COMMAND" | grep -qE 'python run\.py down|docker compose down.*--volumes'; then
    echo "Blocked: This destroys all Postgres data (scans, reports, projects). Run manually if intentional." >&2
    exit 2
  fi

  # Block force push
  if echo "$COMMAND" | grep -qP 'git push.+--force(?!-with-lease)'; then
    echo "Blocked: --force push not allowed. Use --force-with-lease if necessary." >&2
    exit 2
  fi

  # Block direct SonarQube token exposure
  if echo "$COMMAND" | grep -q 'squ_38ae'; then
    echo "Blocked: Do not use the SonarQube token directly in commands. Use the SONARQUBE_TOKEN env var." >&2
    exit 2
  fi
fi

exit 0

