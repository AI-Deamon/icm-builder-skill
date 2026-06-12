---
name: icm-builder
description: >
  Builds a complete, production-grade Interpretable Context Methodology (ICM) workspace from
  scratch for any development project. Produces AGENTS.md, root CONTEXT.md, per-room CONTEXT.md
  files, Layer 3 skill files with proper YAML frontmatter, MCP server configuration (.mcp.json),
  hooks configuration (settings.json), a self-evaluation rubric, and optional subagent definitions.
  Trigger on: "set up ICM for my project", "create my workspace files", "build my AGENTS.md",
  "help Claude understand my project", "scaffold my context files", "I want to use ICM",
  "rebuild my workspace", "create room files", "set up folder architecture", or any request to
  make a project AI-readable via structured markdown files. Also trigger when a user shares a
  project description and wants persistent, session-independent Claude understanding.
allowed-tools: Read Bash(find:*) Bash(ls:*) Bash(cat:*)
---

# ICM Builder — Development Edition

You are a workspace architect. Your output is a complete, immediately deployable ICM workspace
for a software development project. Every file you produce eliminates the need to re-explain
context to Claude across sessions.

Read the reference files ONLY when needed — do not load them upfront:
- `references/layer1-patterns.md` — AGENTS.md patterns and anti-patterns
- `references/layer2-patterns.md` — Room CONTEXT.md patterns and anti-patterns
- `references/layer3-skills-guide.md` — How to write proper Layer 3 skill files
- `references/mcp-integration-guide.md` — MCP server selection and .mcp.json format
- `references/hooks-guide.md` — Hook patterns for deterministic enforcement
- `references/self-evaluation-framework.md` — Self-audit protocol and rubric
- `references/subagents-guide.md` — When and how to define subagents
- `references/examples/` — Complete worked examples by project type

---

## SELF-AWARENESS PROTOCOL

Before any phase, Claude must know its own state. After reading this skill, Claude must be
able to answer all of these truthfully:

- Which context files am I currently holding? (loaded from this conversation)
- Which room am I operating in right now?
- What phase of this skill am I executing?
- What have I produced so far, and what remains?
- What is the quality bar I must hit before delivering?

If Claude cannot answer these, it must say so before proceeding.

---

## Phase 0: Context Check

Before asking the user a single question, check if the user has already shared project
information in this conversation. If they have:
- Extract what you already know (tech stack, folders, commands, team size, failure patterns)
- List what you still need
- Ask only for what is missing

If the conversation has no project context, proceed to Phase 1.

Never ask questions the user already answered. Never ask all questions in multiple messages —
group everything into one interview message.

---

## Phase 1: Development Project Interview

Send ONE message containing all of these grouped questions. Do not proceed until you have
concrete answers. If an answer is vague, push back once with a specific follow-up. After one
follow-up, make a stated assumption and move on.

### Group A — Project identity
1. What does this project do? (One sentence, README quality)
2. Tech stack — languages, frameworks, databases, infrastructure, external services
3. What are the exact commands to: start dev server, run tests, build for production, deploy?
4. Monorepo or single repo? If monorepo, what are the packages?

### Group B — Work types (these become your rooms)
5. What are the distinct types of work you do? List every mode you shift between.
   Examples: backend API, frontend, infrastructure, writing specs, running tests, docs,
   security audits, CI/CD pipeline, data migration
6. Which do you switch between most often in a single session?
7. Are there areas that must NEVER be touched when working in another area?
   (Example: "never edit the frontend while working on the Jenkinsfile")

### Group C — External systems (these become your MCP servers)
8. Which external systems does Claude need to reach during work?
   Examples: GitHub (PRs/issues), Jira/Linear (tickets), Postgres/MySQL (query live data),
   Sentry (errors), Slack (notifications), Figma (designs), Jenkins/CI logs
9. For each: read-only access or read-write?

### Group D — Failure patterns (these become hard rules and hooks)
10. What has gone wrong before that Claude specifically caused or could cause?
11. What are the "never do this" rules a new developer learns the hard way?
12. Any: file naming traps, service ordering issues, migration gotchas, environment conflicts,
    commands that look safe but destroy data?

### Group E — Naming and output conventions
13. How do you name: spec/design docs, drafts, final versions, versioned outputs, test files?
14. Where should generated files go? Any folders that are read-only or off-limits?

### Group F — Self-evaluation target
15. How will you know Claude is doing good work in this project?
    What does a bad Claude output look like? What does a good one look like?

---

## Phase 2: Architecture Design (confirm before building)

After receiving answers, present this plan for confirmation before writing any file:

```
Project: [name] — [one sentence]

Proposed rooms:
  [room-name]/  — [one-line purpose] — persona: [specific engineer role]
  [room-name]/  — [one-line purpose] — persona: [specific engineer role]
  ...

Routing table (preview):
  "Add endpoint / fix API bug"     → [room]/CONTEXT.md
  "Fix UI component"               → [room]/CONTEXT.md
  ...

MCP servers to wire:
  [system] — [read/write] — [why needed]
  ...

Hooks to create:
  PreToolUse: [what to block and why]
  PostToolUse: [what to auto-run and why]
  ...

Layer 3 skills to create:
  [skill-name] — [trigger phrase] — [what it does]
  ...

Naming conventions:
  [type]  →  [pattern]  →  [example]
  ...

Hard rules from your failure patterns:
  [rule 1]
  [rule 2]
  ...
```

Ask: "Does this match how you actually work? Anything wrong, missing, or to rename?"

Adjust based on feedback. Then proceed to Phase 3.

---

## Phase 3: Build Layer 1 — AGENTS.md

AGENTS.md is always loaded. It must be short (50-70 lines), navigation-focused, and contain
zero generic content.

Required sections, in this order:

```markdown
# AGENTS.md

[Project name] — [one sentence describing what it is and does]

## Commands

### [Group 1]
```bash
[exact runnable command]   # [one-line note]
[exact runnable command]   # [one-line note]
```

### [Group 2]
```bash
[exact runnable command]
```

[only include groups that exist. no placeholders.]

## Architecture

| Layer | Path | Notes |
|-------|------|-------|
| [real layer name] | `[exact path]` | [one-line note about what lives here] |

## Routing Table

| User intent | Room | Read |
|-------------|------|------|
| [real intent phrase user would type] | `[path]/` | `[path]/CONTEXT.md` |

[6-10 rows. Use real intent phrases, not category names like "backend" or "code".]

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| [type] | `[pattern]` | `[real example]` |

## Gotchas

- **[Short title]**: [What the trap is and what to do instead — one sentence each]

## Style

- [Real project convention, not generic advice]
```

### AGENTS.md self-check (run before outputting):
- [ ] Every command is copy-paste runnable (no `[your-env]` etc.)
- [ ] Routing table uses intent phrases, not category names
- [ ] Every gotcha is project-specific (not "be careful with migrations" generically)
- [ ] File fits in 50-70 lines — if longer, content belongs in a room CONTEXT.md
- [ ] No section is empty or placeholder-filled

---

## Phase 4: Build Layer 1 — Root CONTEXT.md

This file's only job is routing. It must be short.

```markdown
# CONTEXT.md

## The Silo Rule

[Project name] is siloed by work type. Read only the target room's CONTEXT.md.
Never load files from Room A while working in Room B.
`AGENTS.md` is always loaded. Each room's CONTEXT.md defines its own load/skip budget.

## Intent → Room Routing

| If the user wants to... | Go to | Context file |
|-------------------------|-------|--------------|
| [real intent] | `[room path]` | CONTEXT.md |

[Same rows as AGENTS.md routing table. Add detail where needed.]

## First Move (SOP)

1. **Identify intent** — match the user's request to the routing table
2. **Teleport** — read only the target room's CONTEXT.md
3. **Execute** — follow that room's process and hard rules exactly
4. **Self-check** — before marking done, run the room's verification commands
```

---

## Phase 5: Build Layer 2 — Room CONTEXT.md files

For EACH room, produce a complete CONTEXT.md. No room gets a skeleton or placeholder.

Template (every section is mandatory — write project-specific content in every one):

```markdown
# CONTEXT.md — [room-name]/

**Last updated**: [today's date YYYY-MM-DD]
**Location**: `[path]/` at repo root
**Layer**: 2 (Distributed)

## 1. Room Definition

**Persona**: [Real engineering role — e.g. "FastAPI / Celery Engineer"]
**Objective**: [One sentence starting with an action verb — what this room produces]

## 2. Token Budget

| Task | Load | Skip |
|------|------|------|
| [specific task type] | `[files/folders]` | `[rooms/files to never load]` |

[4-8 rows. Each row = one concrete task type, not a category.
Every row must have a non-empty Skip column.]

## 3. Local Map

```
[room-name]/
├── [actual file or folder]    # [one-line note]
├── [actual file or folder]    # [one-line note]
[...real structure only. no invented paths.]
```

## 4. The Process

1. **Source** — [what to read first and why]
2. **Plan** — [what to draft/decide before writing code]
3. **Execute** — [what to write/build]
4. **Refine** — [real verification commands that must pass]

## 5. What Good Looks Like

- [Measurable or observable quality bar — not subjective advice]
- [Measurable or observable quality bar]
- [Measurable or observable quality bar]

## 6. Constraints

- **[Label]**: [What not to do and why — one sentence each]

## 7. Skills Available in This Room

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `/[skill-name]` | [when to invoke] | [what it runs] |

[Only list skills that actually apply to this room. Omit section if none.]

## 8. MCP Servers Available in This Room

| Server | Access | Use for |
|--------|--------|---------|
| `[server-name]` | [read/write] | [specific use cases] |

[Only list MCPs that this room needs. Omit section if none.]

## 9. Hard Rules

- **Thou shalt NOT [rule].** [Consequence — what breaks, what data is lost, what downstream effect occurs.]

[Minimum 2, maximum 6. Every rule must have a stated consequence.]
```

### Room CONTEXT.md self-check (run for each room before outputting):
- [ ] Persona is a real engineering role (not "helpful assistant" or "AI")
- [ ] Every token budget row has a concrete Skip target
- [ ] Local map uses only real paths confirmed by user
- [ ] Process step 4 contains runnable verification commands
- [ ] Quality bars are measurable (not "write clean code")
- [ ] Every hard rule states a consequence

---

## Phase 6: Build Layer 3 — Skill Files

Skills are reusable workflows Claude can invoke instead of re-explaining a process every
session. Each skill lives at `.claude/skills/[skill-name]/SKILL.md`.

Read `references/layer3-skills-guide.md` before writing any skill.

### When to create a skill (vs. other mechanisms)

| The need is... | Use this |
|----------------|----------|
| Claude forgets a multi-step process | Skill |
| Something must happen every time, no exceptions | Hook |
| Claude needs to reach an external system | MCP |
| Work needs its own context window to avoid contamination | Subagent |
| A task needs human review before proceeding | Manual checkpoint (note in CONTEXT.md) |

### Standard development skills to offer for every project

Ask the user which they want. Create only what was requested.

**`systematic-debugging`** — triggers on: "test fails", "error I can't fix", "this is broken"

```markdown
---
name: systematic-debugging
description: >
  Use when facing a bug, failing test, or unexpected behaviour. Forces hypothesis-first
  debugging — state the suspected root cause before touching code, then verify or disprove.
  Prevents the "change random things until it works" pattern.
allowed-tools: Read Bash(cat:*) Bash(grep:*) Bash(find:*)
---

# Systematic Debugging

## When to invoke
- A test fails and the cause is not immediately obvious
- A feature behaves unexpectedly in one environment but not another
- The user says "I can't figure out why this is broken"
- You are about to make your second consecutive guess-and-check edit

## Protocol

1. **Stop editing.** Do not change any code yet.

2. **State your hypothesis.** Write one sentence: "I believe the failure is caused by [X]
   because [Y evidence]." If you cannot state a hypothesis, say so — that is the first
   data point.

3. **Read the failure evidence.** Read the full error message or stack trace. Do not skim.
   Identify: the error type, the file and line, the call stack up to your code.

4. **Check the narrowest possible scope first.** Before reading the whole module, check
   the specific function the error points to.

5. **Verify, don't assume.** Run the failing test in isolation:
   `[project-specific test command for a single test]`
   Read the actual output. Compare to your hypothesis.

6. **If hypothesis was wrong:** write a new one. Repeat from step 4. Do not make more
   than 3 edit attempts on the same hypothesis.

7. **If two consecutive hypotheses fail:** call `/clear`, state the situation from scratch
   in a fresh session. Context accumulation is now working against you.

8. **When hypothesis is confirmed:** make the minimal change that fixes the root cause.
   Do not fix symptoms. Do not clean up unrelated code in the same commit.

9. **Verify the fix:** run the test suite. The specific test must pass. No regressions.

## Done when
- The originally failing test passes
- The full test suite passes (no new failures)
- You can state what the root cause was and why the fix addresses it
```

**`verification-before-completion`** — triggers on: "I'm done", "feature complete", before any PR

```markdown
---
name: verification-before-completion
description: >
  Use before marking any feature, bug fix, or task as complete. Runs the project's full
  verification sequence — lint, typecheck, test suite, build — and blocks completion until
  all pass. Prevents "looks done" from being the only signal.
allowed-tools: Bash
---

# Verification Before Completion

## When to invoke
- Before saying "done", "complete", or "finished" on any task
- Before opening a PR or pushing to a shared branch
- After any change to shared types, interfaces, or API contracts
- When the user asks "is this ready?"

## Protocol

Run these in order. Stop and report failure at the first step that fails.
Do not skip steps. Do not declare done if any step produces errors or warnings.

1. **Lint**
   `[project lint command]`
   Expected: zero errors. Warnings are acceptable only if pre-existing.

2. **Type check**
   `[project typecheck command]`
   Expected: zero type errors. No `// @ts-ignore` added without a comment explaining why.

3. **Test suite**
   `[project test command]`
   Expected: all tests pass. No skipped tests that were not already skipped before this task.

4. **Build**
   `[project build command]`
   Expected: build succeeds. Zero new warnings in the output.

5. **Smoke check** (if applicable)
   Start the dev server: `[dev command]`
   Navigate to the affected feature. Verify it works as expected visually or via curl.

## Report format

After running:
```
Verification result:
- Lint: PASS / FAIL ([N] errors)
- Typecheck: PASS / FAIL ([N] errors)
- Tests: PASS / FAIL ([N] failures — list them)
- Build: PASS / FAIL
- Smoke check: PASS / FAIL / SKIPPED

Verdict: READY / NOT READY
Blockers: [list anything that failed]
```

## Done when
All steps show PASS. The verdict is READY.
If any step fails, fix it and re-run the full sequence from step 1.
```

**`pre-commit-checklist`** — triggers on: "commit this", "git commit", "push this"

**`code-review-prep`** — triggers on: "open a PR", "ready for review", "review this"

**`spec-writer`** — triggers on: "write a spec", "plan this feature", "design this"

For each skill requested, follow the same structure:
1. YAML frontmatter: name, description (starts with "Use when..."), allowed-tools
2. ## When to invoke (specific trigger phrases and conditions)
3. ## Protocol (numbered steps — concrete, runnable)
4. ## Done when (clear completion criteria)

---

## Phase 7: Build MCP Server Configuration

Read `references/mcp-integration-guide.md` before writing this section.

### Decision rule: MCP vs. not

Add an MCP server when Claude needs to reach an external system (GitHub, database, CI logs,
issue tracker) that it cannot reach by reading files or running local commands.

Do NOT add an MCP server for:
- Information that can be read from local files
- Tasks that work fine with Claude Code's native bash/file tools
- Systems the user said they don't need Claude to access directly

### Output: `.mcp.json` at repo root (shared, committed)

```json
{
  "mcpServers": {
    "[server-name]": {
      "type": "stdio",
      "command": "[command]",
      "args": ["[args]"],
      "env": {
        "[ENV_VAR]": "${env:[ENV_VAR]}"
      }
    },
    "[remote-server-name]": {
      "type": "http",
      "url": "https://[vendor-mcp-endpoint]"
    }
  }
}
```

### Output: Installation guide for each MCP

For each server, provide:
```
## [Server name] MCP

Install: [exact install command]
Configure: [what env var to set and where]
Verify: [command to confirm it's working]
Used in rooms: [list which room CONTEXT.md files reference this server]
Used for: [specific tasks this enables]
```

### Reference: Common MCP servers for dev projects

| System | Server | Type | Install |
|--------|--------|------|---------|
| GitHub | `github/github-mcp-server` (official) | remote | `claude mcp add github ...` |
| PostgreSQL | `crystaldba/postgres-mcp` | stdio | `claude mcp add postgres ...` |
| Linear | official at `linear.app/docs/mcp` | http | URL config |
| Sentry | official | remote | `claude mcp add sentry ...` |
| Slack | `slackapi/slack-mcp-plugin` | remote | URL config |
| Playwright | Microsoft official | stdio | `npx @playwright/mcp` |
| Jenkins | `jenkins-mcp-server` (community) | stdio | varies |

Prefer first-party vendor servers over community forks.
One MCP per external system — do not add multiple servers for the same system.
Token cost: a five-server setup can consume 50k+ tokens upfront. Be selective.

---

## Phase 8: Build Hooks Configuration

Read `references/hooks-guide.md` before writing this section.

### The fundamental rule

**Hooks are mandatory enforcement. AGENTS.md/CONTEXT.md are advisory guidance.**

Use hooks for requirements where "Claude forgot" is not an acceptable failure mode.
Use context files for guidance that requires situational judgment.

| Need | Use | Why |
|------|-----|-----|
| Block writes to `.env`, `.key`, secrets | PreToolUse hook | Security cannot be advisory |
| Auto-run linter after every file edit | PostToolUse hook | Must happen every time |
| Prevent `rm -rf` on data directories | PreToolUse hook | Data loss is irreversible |
| Run tests before completing a task | Stop hook | Completion gate |
| Code style conventions | CONTEXT.md | Requires situational judgment |
| API naming patterns | CONTEXT.md | Exception patterns exist |

### Output: hooks section in `.claude/settings.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-sensitive-writes.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
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

### For each hook, produce the actual shell script

Hook scripts receive JSON via stdin. Use exit code 2 to block. Exit code 0 to allow.

Template for a blocking hook:
```bash
#!/bin/bash
# .claude/hooks/[hook-name].sh
set -euo pipefail

INPUT="$(cat)"
TOOL="$(echo "$INPUT" | jq -r '.tool // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

# [Project-specific blocking condition]
if [[ condition ]]; then
  echo "Blocked: [reason]" >&2
  exit 2
fi

exit 0
```

Only create hooks for failure modes the user confirmed in Phase 1 Group D.
Do not create generic hooks for things the user didn't identify as real risks.

---

## Phase 9: Self-Evaluation Framework

Read `references/self-evaluation-framework.md` before writing this section.

Every ICM workspace must include a self-evaluation rubric — a file that tells Claude
how to grade its own output and when it's truly done.

### Output: `.claude/self-eval.md`

```markdown
# Self-Evaluation Rubric — [Project Name]

Claude must run this rubric before marking any task as complete.
Score each dimension. If any dimension scores below 3, the task is NOT done.

## Dimensions

### 1. Correctness (1-5)
5 — All verification commands pass. Tests green. Build succeeds. No lint errors.
4 — Verification passes with minor pre-existing warnings (not introduced by this task).
3 — Primary test passes. Minor unrelated failures exist and were pre-existing.
2 — Some tests fail. Build succeeds but with new warnings.
1 — Tests fail. Build fails. Lint has new errors.

### 2. Scope Discipline (1-5)
5 — Changed only what was needed. No unrelated refactors. No opportunistic cleanups.
4 — One small unrelated cleanup, clearly noted in commit message.
3 — Minor scope creep but all changes are related to the feature area.
2 — Touched files outside the target room without justification.
1 — Changed large areas outside scope. Other rooms affected.

### 3. Context Adherence (1-5)
5 — Followed the room's CONTEXT.md exactly. No improvisation outside stated process.
4 — Followed the room's process with one justified deviation, stated explicitly.
3 — Followed the process generally but skipped one step.
2 — Used the wrong room's context or ignored the token budget.
1 — Did not load any CONTEXT.md. Worked without project-specific context.

### 4. Output Quality (1-5)
5 — Output matches "What Good Looks Like" criteria in the room's CONTEXT.md exactly.
4 — Meets most quality bars. One minor deviation, noted.
3 — Meets the primary quality bar. Minor gaps in secondary criteria.
2 — Output works but does not meet the stated quality bars.
1 — Output is incomplete or does not work.

### 5. Hard Rule Compliance (1-5)
5 — No hard rules violated. Every "Thou shalt NOT" was respected.
3 — Followed all hard rules but one was borderline.
1 — A hard rule was violated. This is a blocking failure regardless of other scores.

## Scoring

Total score: [sum of 5 dimensions] / 25

- 23-25: Done. Ready to commit or hand off.
- 18-22: Done with notes. Document the gaps in the commit message.
- 13-17: Not done. Identify the lowest-scoring dimension and fix it first.
- Below 13: Restart the task. Call /clear if needed to avoid context contamination.

## Self-report format

Before any "done" statement:
```
Self-evaluation:
- Correctness: [score] — [one line of evidence]
- Scope Discipline: [score] — [one line of evidence]
- Context Adherence: [score] — [one line of evidence]
- Output Quality: [score] — [one line of evidence]
- Hard Rule Compliance: [score] — [one line of evidence]

Total: [N]/25
Verdict: DONE / NOT DONE
```
```

---

## Phase 10: Subagent Definitions (optional)

Read `references/subagents-guide.md` before writing this section.

Offer subagent definitions when the project has recurring tasks that benefit from:
- **Context isolation** — the task generates so much output it would pollute the main session
- **Parallelisation** — multiple independent tasks can run simultaneously
- **Bias prevention** — the agent doing the work shouldn't also grade it

Common dev subagents to offer:
- `code-reviewer` — reviews changes in an isolated context, unaffected by implementation decisions
- `test-writer` — writes tests without the bias of knowing the implementation
- `spec-writer` — plans features without being pushed toward a specific implementation

Subagent files live at `.claude/agents/[agent-name].md`:

```markdown
---
name: [agent-name]
description: [Use when... trigger phrase]. [What it does in one sentence.]
tools: Read, Bash, [other tools]
model: sonnet
skills:
  - [skill-name]
---

You are a [specific role]. [One sentence objective.]

[Specific instructions for this agent's behaviour.]
[What it should produce.]
[What it should never do.]
```

---

## Phase 11: Deliver

Output everything in this order. Each file is a separate fenced code block with the file
path as its label. No file is optional if it was confirmed in Phase 2.

**Delivery order:**
1. `AGENTS.md`
2. `CONTEXT.md`
3. `[room1]/CONTEXT.md`
4. `[room2]/CONTEXT.md`
5. `[roomN]/CONTEXT.md`
6. `.claude/skills/[skill-name]/SKILL.md` (one per skill)
7. `.claude/settings.json` (hooks config)
8. `.claude/hooks/[hook-name].sh` (one per hook)
9. `.mcp.json`
10. `.claude/self-eval.md`
11. `.claude/agents/[agent-name].md` (if requested)

Then provide this install guide, with all placeholders filled in:

```
## Install guide for [project name]

### 1. Context files
cp AGENTS.md [your-project-root]/
cp CONTEXT.md [your-project-root]/
cp [room]/CONTEXT.md [your-project-root]/[room]/
[... one line per file]

### 2. Claude Code setup
mkdir -p .claude/skills .claude/hooks .claude/agents
cp .claude/skills/[skill]/SKILL.md [your-project-root]/.claude/skills/[skill]/
chmod +x .claude/hooks/*.sh
cp .claude/settings.json [your-project-root]/.claude/

### 3. MCP servers
[exact install command for each server]
[what env var to set]

### 4. Verify the workspace
cd [your-project-root] && claude
Ask: "What room should I be in to add a new [feature]?"
Expected: Claude names the correct room without you explaining anything.

### 5. Test self-evaluation
Ask Claude to do a small task, then ask: "Run your self-evaluation."
Expected: Claude produces a scored self-eval report, not just "done".
```

---

## MASTER QUALITY GATE

Run this checklist against EVERY file before outputting it.
If any item fails, fix it before outputting the file. No exceptions.

**Placeholder check:**
- [ ] Zero `[bracket]` placeholders in any file
- [ ] Zero `TODO`, `FIXME`, or `your-project-here` strings
- [ ] Zero generic examples that don't match this project

**Content check:**
- [ ] Every command is copy-paste runnable
- [ ] Every file path was confirmed by the user (not invented)
- [ ] Every gotcha is project-specific (not generic developer advice)
- [ ] Every hard rule states a consequence (what breaks)
- [ ] Every quality bar is measurable (not subjective)

**Structure check:**
- [ ] AGENTS.md is 50-70 lines
- [ ] Routing table uses real intent phrases (not category names)
- [ ] Every room CONTEXT.md has a non-empty Skip column in the token budget
- [ ] Every skill file has valid YAML frontmatter with name, description, allowed-tools
- [ ] Hook scripts use exit code 2 to block (not print-and-exit-0)

**Self-awareness check:**
- [ ] The workspace tells Claude what state it's in (which room, which phase)
- [ ] The self-eval rubric gives Claude a scoring mechanism it can run itself
- [ ] The hard rules tell Claude what the consequence of violation is
- [ ] The skill trigger conditions are specific enough that Claude won't over-invoke them

