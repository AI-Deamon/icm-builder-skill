# ICM Builder — Universal Edition

> **Any AI coding agent can run this file.** If you are an AI agent (Claude Code, OpenCode,
> Gemini CLI, Cursor, Copilot, or any other) and a user pointed you here, read this file
> top to bottom and execute it. No plugin system required.

You are a workspace architect. Your output is a complete, immediately deployable
**Interpretable Context Methodology (ICM)** workspace: a root `AGENTS.md` that tells any
agent everything about the codebase, a `CONTEXT.md` in every working folder (room), and
tooling rules that tell the agent when to use which skill or MCP instead of wasting tokens
on blind grep/glob searches. Every file you produce eliminates the need to re-explain
context across sessions.

**Why this matters**: without ICM, an agent re-discovers the codebase every session —
searching, guessing, loading irrelevant files. With ICM, it reads one routing table and
teleports to the right room with the right context on the first try.

Reference files (read ONLY when the phase tells you to — never load them all upfront):

- `references/layer1-patterns.md` — AGENTS.md patterns and anti-patterns
- `references/layer2-patterns.md` — Room CONTEXT.md patterns and anti-patterns
- `references/layer3-skills-guide.md` — Writing Layer 3 skill files
- `references/mcp-integration-guide.md` — MCP server selection and config format
- `references/hooks-guide.md` — Hook patterns (Claude Code / OpenCode)
- `references/self-evaluation-framework.md` — Self-audit rubric
- `references/subagents-guide.md` — When and how to define subagents
- `references/output-adapters.md` — Generating per-tool entry files (CLAUDE.md, GEMINI.md, .cursor/rules, OpenCode)
- `references/update-mode.md` — Drift detection and patching an existing ICM workspace

---

## SELF-AWARENESS PROTOCOL

At every phase you must be able to answer: Which mode am I in (FRESH or UPDATE)? Which
phase am I executing? What have I produced so far and what remains? What quality bar must
I hit before delivering? If you cannot answer these, say so before proceeding.

---

## Phase 0: Mode Detection

Check the project root:

1. `AGENTS.md` exists AND contains the marker `<!-- icm:managed -->` → **UPDATE mode**.
   Read `references/update-mode.md` and follow it. Do not continue with the fresh phases.
2. `AGENTS.md` exists without the marker → the user has hand-written context. Ask whether
   to absorb it into a new ICM workspace (preserving their content) or leave it untouched.
   Absorb → continue to Phase 1, treating the existing file as scan input. Leave untouched
   → stop here; generate or modify nothing.
3. No `AGENTS.md` → **FRESH mode**. Continue to Phase 1.

---

## Phase 1: Scan the Codebase (before asking anything)

Never ask the user something the codebase can tell you. Scan first.

**If you can run shell commands**: run `scripts/scan.sh` from this skill's directory with
the project root as argument:

```bash
bash scripts/scan.sh /path/to/project
```

It reports: languages, frameworks, package manager, runnable commands (dev/test/build/lint),
folder tree, monorepo layout, CI config, test setup, existing agent-context files.

**If you cannot run shell commands**, scan manually by reading, in this order:

1. Manifests: `package.json` (scripts block = commands), `pyproject.toml`, `requirements.txt`,
   `go.mod`, `Cargo.toml`, `pom.xml`, `composer.json`, `Gemfile`
2. Folder tree, 2 levels deep, ignoring `node_modules`, `.git`, `dist`, `build`, `venv`,
   `__pycache__`, `.next`, `target`
3. Monorepo signals: `pnpm-workspace.yaml`, `lerna.json`, `turbo.json`, `nx.json`,
   `workspaces` field, `packages/` or `apps/` folders
4. CI and infra: `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, `Dockerfile`,
   `docker-compose*.yml`
5. Test setup: `jest.config.*`, `vitest.config.*`, `pytest.ini`, `playwright.config.*`,
   `cypress.config.*`, test folder locations
6. Existing agent context: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/`,
   `.cursorrules`, `.github/copilot-instructions.md`, `opencode.json`, `.claude/`
7. README (first 50 lines) for the project's own description of itself

Without a shell, you're composing every file by hand — use
`assets/templates/blank-templates.md` as the starting scaffold for AGENTS.md, room
CONTEXT.md, skills, hooks, and subagents, and replace every `[bracket]`.

After scanning, present a **Scan Summary** to the user:

```
Scan summary:
- Project: [inferred one-liner from README/manifest]
- Stack: [languages, frameworks, DB, infra found]
- Commands found: dev=[cmd] test=[cmd] build=[cmd] lint=[cmd]
- Layout: [single repo / monorepo with packages X, Y]
- Candidate rooms (from folder structure, or cross-cutting concerns if folders don't
  match how work actually splits): [list]
- Existing agent context files: [list or none]
- Could NOT determine: [list]
```

---

## Phase 2: Interview (only what the scan could not tell you)

Ask ONE message with only the questions that remain unanswered. Never re-ask something the
scan or the conversation already answered. If an answer is vague, push back once with a
specific follow-up; after that, make a stated assumption and move on.

The full question bank — ask only the unanswered ones:

1. **Confirm the scan.** "Is the scan summary right? Anything wrong or missing?"
2. **Work types** (become rooms): What distinct modes of work do you shift between?
   Which folders must NEVER be touched while working in another folder? If a mode of work
   doesn't live in one folder — a cross-cutting concern, a single-file or flat-script
   project, a feature-sliced architecture — define that room by a file glob or explicit
   file list instead of a path; Phase 6's Local Map accepts either.
3. **External systems** (become MCP servers): Which systems should the agent reach —
   GitHub/GitLab, issue tracker, database, error tracker, Slack, Figma, CI logs?
   For each: read-only or read-write?
4. **Failure patterns** (become hard rules and hooks): What has an AI agent (or new
   developer) broken before? Commands that look safe but destroy data? File-naming traps?
   Ordering issues?
5. **Naming conventions**: How do you name specs, drafts, finals, versioned outputs, tests?
   Where should generated files go? Any read-only folders?
6. **Quality bar**: What does a bad agent output look like in this project? A good one?
7. **Agent tooling** (decides Phase 9's output): Which AI coding tools does your team
   use — Claude Code, Cursor, Gemini CLI, GitHub Copilot, OpenCode, others? Generate
   entry files only for tools someone actually uses.

---

## Phase 3: Architecture Plan (confirm before building)

Room-count sanity check before drafting the plan: fewer than 2 rooms means the project is
too small for routing to earn its keep — Phase 4's Routing Table can drop below its usual
6–10 rows (even to a single row) rather than inventing distinctions that don't exist. More
than ~12 usually means the rooms are too fine-grained to beat a plain folder tree — merge
adjacent ones (e.g. by top-level package) until routing stays genuinely quicker than just
reading the Architecture table. Exception: a monorepo with many independently-owned
packages that each have real, distinct conventions. Forcing those under ~12 rows would
blur contexts that actually differ — nest instead of merging: give the root Routing Table
one row per package, and have each package's own CONTEXT.md repeat the Phase 5 pattern
(its own "Intent → Room Routing" table) pointing to that package's internal rooms. Root
AGENTS.md and root CONTEXT.md stay within budget either way; only the nesting depth changes.

Present this plan and get explicit confirmation before writing any file:

```
Project: [name] — [one sentence]

Proposed rooms:
  [room-name]/  — [one-line purpose] — persona: [specific engineer role]
  ...

Routing table (preview):
  "[real user intent phrase]" → [room]/CONTEXT.md
  ...

Tooling rules (when to use what — goes in AGENTS.md):
  [task type] → [skill/MCP/routing table] instead of [wasteful default e.g. repo-wide grep]
  ...

MCP servers: [system] — [read/write] — [why]
Hooks (Claude Code/OpenCode only): [what to block/auto-run and why]
Layer 3 skills: [name] — [trigger] — [what it does]
Naming conventions: [type] → [pattern] → [example]
Hard rules from failure patterns: [rules]

Per-tool entry files to generate: [from Phase 2 question 7 — e.g. CLAUDE.md, GEMINI.md,
.cursor/rules/icm.mdc, .github/copilot-instructions.md]
```

Ask: "Does this match how you actually work? Anything wrong, missing, or to rename?"
Adjust, then build.

---

## Phase 4: Build Layer 1 — AGENTS.md (root, source of truth)

`AGENTS.md` is the single source of truth. Per-tool files (CLAUDE.md etc.) are generated
copies of it (Phase 9). It must be short (50–80 lines), navigation-focused, zero generic
content. Read `references/layer1-patterns.md` before writing it.

Required sections, in order:

```markdown
<!-- icm:managed generated=[YYYY-MM-DD] builder=icm-builder -->
# AGENTS.md

[Project name] — [one sentence: what it is and does]

## Commands

```bash
[exact runnable command]   # [one-line note]
```

## Architecture

| Layer | Path | Notes |
|-------|------|-------|
| [real layer] | `[exact path]` | [one line] |

## Routing Table

| User intent | Room | Read |
|-------------|------|------|
| [real intent phrase] | `[path]/` | `[path]/CONTEXT.md` |

[6–10 rows normally, fewer if Phase 3's room-count check found under 2 rooms. Real intent
phrases, never category names like "backend" or "code". Room column holds a glob (e.g.
`src/billing/**`, `**/*Stripe*`) instead of a folder when the room is cross-cutting rather
than folder-rooted — see Phase 2 Q2.]

## Tooling Rules — read this before searching or acting

| Before you... | Do this instead |
|---------------|-----------------|
| grep/glob the whole repo for where something lives | Match the task to the Routing Table above and read that room's CONTEXT.md |
| re-explore the folder structure | Read the Architecture table above |
| guess a file name or location | Check Naming Conventions below |
| [reach external system X] | Use the `[mcp-name]` MCP ([read/write]) |
| [do recurring multi-step task Y] | Invoke the `[skill-name]` skill |
| notice a new top-level folder, changed command, or missing room | Re-run icm-builder in UPDATE mode |

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|

## Gotchas

- **[Short title]**: [trap + consequence + what to do instead — one sentence]

## Style

- [Real project convention only]
```

The **Tooling Rules** table is mandatory. It is what stops agents from forgetting that
skills and MCPs exist — the rules live in the always-loaded file, so every session sees
them without needing to remember anything.

**AGENTS.md self-check**: every command copy-paste runnable · routing intents are phrases
not categories · every gotcha project-specific · 50–80 lines · Tooling Rules present ·
`<!-- icm:managed -->` marker present · no empty/placeholder sections.

---

## Phase 5: Build Layer 1 — Root CONTEXT.md

Routing only. Short.

```markdown
# CONTEXT.md

## The Silo Rule

[Project name] is siloed by work type. Read only the target room's CONTEXT.md.
Never load files from Room A while working in Room B.
AGENTS.md is always loaded. Each room's CONTEXT.md defines its own load/skip budget.

## Intent → Room Routing

| If the user wants to... | Go to | Context file |
|-------------------------|-------|--------------|
[same rows as AGENTS.md routing table, with detail where needed]

## First Move (SOP)

1. **Identify intent** — match the request to the routing table
2. **Teleport** — read only the target room's CONTEXT.md
3. **Execute** — follow that room's process and hard rules exactly
4. **Self-check** — run the room's verification commands before saying done. If this task
   spans multiple rooms, touches shared types, or is about to be committed/handed off, also
   run `.icm/self-eval.md` (Level 3) — not required for routine single-room tasks
```

---

## Phase 6: Build Layer 2 — Room CONTEXT.md files

One complete CONTEXT.md per room. No skeletons, no placeholders. Read
`references/layer2-patterns.md` before writing the first room.

If this room is itself a package containing further nested rooms (Phase 3's monorepo
exception), add an "Intent → Room Routing" section before the sections below, using the
exact pattern from Phase 5's root CONTEXT.md — same table, scoped to this package.

Mandatory sections per room (full templates and examples in the reference):

1. **Room Definition** — persona (real engineering role) + one-sentence objective
2. **Token Budget** — table of task → Load / Skip. Every row has a non-empty Skip column.
3. **Local Map** — real folder tree of this room, one-line notes; for a room defined by a
   glob/file list instead of a folder, list the actual files (grouped by concern, not
   directory) with the same one-line notes
4. **The Process** — Source → Plan → Execute → Refine (step 4 = runnable verify commands)
5. **What Good Looks Like** — measurable quality bars only
6. **Constraints** — what not to do and why
7. **Skills Available in This Room** — only skills that apply here (omit if none)
8. **MCP Servers Available in This Room** — only what this room needs (omit if none)
9. **Hard Rules** — 2–6 rules, each with a stated consequence

**Room self-check**: persona is a real role · every Skip cell non-empty · only real
confirmed paths · verify commands runnable · quality bars measurable · every hard rule
states a consequence.

---

## Phase 7: Build Layer 3 — Skills, MCP, Hooks, Subagents

Decision rule first — pick the right mechanism:

| The need is... | Use | Works in |
|----------------|-----|----------|
| Agent forgets a multi-step process | Skill | Claude Code, OpenCode, Cowork (others: paste as prompt file) |
| Must happen every time, no exceptions | Hook | Claude Code, OpenCode |
| Reach an external system | MCP | Claude Code, OpenCode, Cursor, Gemini CLI, Cowork |
| Work needs an isolated context window | Subagent | Claude Code, OpenCode |
| Needs human review before proceeding | Manual checkpoint in CONTEXT.md | Everywhere |

Label every generated artifact with its compatibility so users on other tools know what
applies to them. The core ICM files (AGENTS.md + CONTEXT.md) work with every agent.

- **Skills**: read `references/layer3-skills-guide.md`. Offer the standard set
  (`systematic-debugging`, `verification-before-completion`, `pre-commit-checklist`,
  `code-review-prep`, `spec-writer`) and create only what the user requests. Place at
  `.claude/skills/[name]/SKILL.md` and (if the user uses OpenCode) `.opencode/skill/[name]/SKILL.md`.
  For a worked example of this whole phase's output (skills, hooks, `.mcp.json`, and the
  AGENTS.md/CONTEXT.md they're referenced from), see `references/examples/security-tool/`,
  then `references/examples/web-app/` and its `COMPARISON.md` to see what's structural
  (constant across projects) versus what's project-specific (must come from Phase 2, never
  copied from either example).
- **MCP config**: read `references/mcp-integration-guide.md`. Output `.mcp.json` (Claude
  Code) and, if the user uses OpenCode, the `mcp` block for `opencode.json`. One server per
  external system; only systems confirmed in Phase 2. Include an install guide per server.
- **Hooks**: read `references/hooks-guide.md`. Only for failure modes the user confirmed
  in Phase 2 question 4 — never generic hooks. Output `.claude/settings.json` + scripts in
  `.claude/hooks/*.sh` (exit code 2 blocks). Mark clearly: Claude Code only; OpenCode users
  get the equivalent `opencode.json` plugin/permission config where possible.
- **Subagents** (optional): read `references/subagents-guide.md`. Offer only for recurring
  tasks needing context isolation, parallelism, or bias prevention.

---

## Phase 8: Self-Evaluation Rubric

Read `references/self-evaluation-framework.md`. Output `.icm/self-eval.md` — the 5-dimension
rubric (Correctness, Scope Discipline, Context Adherence, Output Quality, Hard Rule
Compliance, each 1–5) with the scoring bands and self-report format. It's already
referenced from the root CONTEXT.md First Move step 4 (Phase 5) — no separate wiring needed.
In OpenCode or Claude Code, also offer the `self-eval-reviewer` subagent (Phase 7,
`references/subagents-guide.md`) so hand-offs get graded independently instead of
self-graded — self-grading is a known weak point of this rubric.

---

## Phase 9: Generate Per-Tool Entry Files

Different agents auto-load different files. Read `references/output-adapters.md` and
generate a **full copy** of AGENTS.md content for each tool the user's team uses:

| Tool | File it auto-loads |
|------|--------------------|
| Claude Code | `CLAUDE.md` |
| Gemini CLI | `GEMINI.md` |
| Cursor | `.cursor/rules/icm.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| OpenCode, Codex, Jules, Amp | `AGENTS.md` (native — no copy needed) |

Every generated copy starts with this header so nobody edits the wrong file:

```markdown
<!-- GENERATED from AGENTS.md by icm-builder on [date]. Do NOT edit this file.
     Edit AGENTS.md, then re-run icm-builder in UPDATE mode to regenerate all copies. -->
```

UPDATE mode regenerates all copies from AGENTS.md, so they can never drift.

---

## Phase 10: Write the ICM Manifest

Output `.icm/manifest.md` — the file UPDATE mode diffs against:

```markdown
# ICM Manifest
Generated: [YYYY-MM-DD]
Builder: icm-builder [version — read the `version:` field from this skill's own SKILL.md
frontmatter; if there isn't one, write "unversioned"]

## Managed files
[list every file generated, one per line, with the room it belongs to]

## Scan snapshot
[the Phase 1 scan summary verbatim — stack, commands, layout, rooms]

## Tools configured for
[list of per-tool entry files generated]
```

---

## Phase 11: Deliver

Write every file to its real path in the project (if you have write access) or output each
as a fenced code block labeled with its path (if you don't). Delivery order:

1. `AGENTS.md` → 2. `CONTEXT.md` → 3. each `[room]/CONTEXT.md` → 4. skills →
5. `.claude/settings.json` + hook scripts → 6. `.mcp.json` (+ `opencode.json` block) →
7. `.icm/self-eval.md` → 8. subagents → 9. per-tool entry files → 10. `.icm/manifest.md`

Then verify the install with the user:

```
### Verify
Open your agent in the project root and ask:
  "What room should I be in to add a new [feature relevant to this project]?"
Expected: the agent names the correct room without any explanation from you.

Then ask it to do a small task and say: "Run your self-evaluation."
Expected: a scored 5-dimension report, not just "done".
```

---

## MASTER QUALITY GATE

Run against EVERY file before outputting. Any failure → fix before output. No exceptions.

**Placeholders**: zero `[bracket]` placeholders · zero TODO/FIXME/your-project-here ·
zero generic examples that don't match this project.

**Content**: every command copy-paste runnable · every path confirmed (scan or user) ·
every gotcha project-specific · every hard rule states a consequence · every quality bar
measurable.

**Structure**: AGENTS.md 50–80 lines with `<!-- icm:managed -->` marker and Tooling Rules
table · routing table uses intent phrases · every room token budget has non-empty Skip ·
skills have valid frontmatter · hook scripts block with exit code 2 · every generated
per-tool copy has the GENERATED header.

**Self-awareness**: the workspace tells the agent which room and phase it is in · the
self-eval rubric is runnable by the agent itself · tooling rules tell the agent when to
use skills/MCPs and when to re-run icm-builder.
