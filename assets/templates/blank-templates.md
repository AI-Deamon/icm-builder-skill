# ICM Blank Templates
# Use these as a starting scaffold when the skill's output needs adjusting.
# Replace every [bracket] before using — a bracket means missing information.

# ─────────────────────────────────────────────────
# AGENTS.md blank template
# ─────────────────────────────────────────────────

# [PROJECT-NAME]

[One sentence: what this project is and what it does.]

## Commands

### [Group Name]
```bash
[command]    # [note]
[command]    # [note]
```

## Architecture

| Layer | Path | Notes |
|-------|------|-------|
| [layer] | `[path]` | [note] |

## Routing Table

| User intent | Room | Read |
|-------------|------|------|
| [intent phrase] | `[path]/` | `[path]/CONTEXT.md` |

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| [type] | `[pattern]` | `[example]` |

## Gotchas

- **[Title]**: [What the trap is and what to do instead.]

## Style

- [Convention]

## Self-Evaluation
Before marking any task done, run `.claude/self-eval.md`. Score ≥ 18 = done.


# ─────────────────────────────────────────────────
# Room CONTEXT.md blank template
# ─────────────────────────────────────────────────

# CONTEXT.md — [room-name]/

**Last updated**: [YYYY-MM-DD]
**Location**: `[path]/` at repo root
**Layer**: 2 (Distributed)

## 1. Room Definition

**Persona**: [Specific engineering role]
**Objective**: [Action verb + what this room produces. One sentence.]

## 2. Token Budget

| Task | Load | Skip |
|------|------|------|
| [specific task] | `[files]` | `[what to never load]` |
| [specific task] | `[files]` | `[what to never load]` |
| [specific task] | `[files]` | `[what to never load]` |
| [specific task] | `[files]` | `[what to never load]` |

## 3. Local Map

```
[room-name]/
├── [file]    # [note]
├── [folder]/ # [note]
```

## 4. The Process

1. **Source** — [what to read first]
2. **Plan** — [what to decide/draft]
3. **Execute** — [what to write/build]
4. **Refine** — `[verification command]` (expected: [what passing looks like])

## 5. What Good Looks Like

- [Measurable quality bar 1]
- [Measurable quality bar 2]
- [Measurable quality bar 3]

## 6. Constraints

- **[Label]**: [What not to do and the consequence if violated.]

## 7. Skills Available in This Room

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `/[skill-name]` | [when] | [what] |

## 8. MCP Servers Available in This Room

| Server | Access | Use for |
|--------|--------|---------|
| `[server]` | [read/write] | [specific use cases] |

## 9. Hard Rules

- **Thou shalt NOT [rule].** [Consequence — what breaks or what data is lost.]
- **Thou shalt NOT [rule].** [Consequence.]


# ─────────────────────────────────────────────────
# Skill SKILL.md blank template
# ─────────────────────────────────────────────────

---
name: [skill-name]
description: >
  Use when [specific trigger condition]. [What this skill does in one sentence.]
  Do not invoke for [anti-use-case].
allowed-tools: Read Bash
---

# [Skill Name]

## When to invoke
- [Specific trigger condition 1]
- [Specific trigger condition 2]
- Do NOT invoke when: [anti-use-case]

## Protocol

1. [Concrete step — not "look at the code"]
2. [Concrete step]
3. [Concrete step with a runnable command: `[command]`]
4. [Verification step — must produce pass/fail evidence]

## Done when
- [Observable criterion 1 — something that can be verified]
- [Observable criterion 2]


# ─────────────────────────────────────────────────
# Hook script blank template
# ─────────────────────────────────────────────────

#!/bin/bash
# .claude/hooks/[hook-name].sh
# Purpose: [One sentence — what behaviour this hook enforces]
# Fires on: [PreToolUse / PostToolUse / Stop] for [matcher]
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

# [Condition that should block]
if [[ condition ]]; then
  echo "Blocked: [Human-readable reason Claude will see]" >&2
  exit 2
fi

exit 0


# ─────────────────────────────────────────────────
# Subagent blank template
# ─────────────────────────────────────────────────

---
name: [agent-name]
description: >
  Use for: [specific tasks]. Do not use for: [anti-use-cases].
  [What this agent does in one sentence.]
tools: Read, Write, Bash
model: sonnet
skills:
  - [skill-name]
---

You are a [specific role]. Your objective: [action verb + outcome].

## What you produce
[Concrete description of the output — format, content, length]

## What you never do
- [Constraint 1]
- [Constraint 2]

## Your process
1. [Step 1]
2. [Step 2]
N. Report back: "[concise format of summary to return to parent]"
