# ICM Builder

**Set up any codebase so AI agents never lose context — and never waste tokens on blind
grep/glob searches.**

ICM (Interpretable Context Methodology) structures a project the way an agent actually
navigates it:

- **Root `AGENTS.md`** — everything about the codebase in 50–80 lines: commands,
  architecture map, an intent→room routing table, naming conventions, gotchas, and
  **Tooling Rules** that tell the agent when to use which skill or MCP instead of
  searching blindly.
- **A `CONTEXT.md` in every working folder ("room")** — persona, token budget
  (what to load / what to skip), local map, process, hard rules with consequences.
- **Per-tool entry files** — full generated copies for `CLAUDE.md` (Claude Code),
  `GEMINI.md` (Gemini CLI), `.cursor/rules/icm.mdc` (Cursor),
  `.github/copilot-instructions.md` (Copilot). OpenCode/Codex/Jules read `AGENTS.md`
  natively.
- **Optional**: Layer 3 skills, MCP server config, hooks, subagents, and a
  self-evaluation rubric the agent scores itself against before saying "done".

The builder **scans your codebase first** (stack, commands, folder tree, tests, CI) and
asks only what it can't infer. It also has an **UPDATE mode** that detects drift — new
folders, changed commands, stale room files — and patches the workspace instead of
regenerating it.

## Use with any agent

The builder itself is model-agnostic. Its full logic lives in one plain-markdown file:
[`ICM-BUILDER.md`](ICM-BUILDER.md).

### Claude Code / Cowork (as a skill)

```bash
mkdir -p .claude/skills/icm-builder
cp -r SKILL.md ICM-BUILDER.md scripts references .claude/skills/icm-builder/
```

Then just say: *"set up ICM for this project"*.

### OpenCode (as a skill)

```bash
mkdir -p .opencode/skill/icm-builder
cp -r SKILL.md ICM-BUILDER.md scripts references .opencode/skill/icm-builder/
```

### Gemini CLI, Cursor, Codex, or any other agent

No install needed. Clone this repo (or copy `ICM-BUILDER.md` + `scripts/` + `references/`
anywhere) and tell your agent:

> Read ICM-BUILDER.md and follow it to set up ICM for my project at [path].

### Updating an existing ICM workspace

Any agent, any time:

> Read ICM-BUILDER.md and run UPDATE mode on my project.

The builder finds the `<!-- icm:managed -->` marker, re-scans, shows you a drift report,
and patches only what changed.

## Repo layout

```
icm-builder-skill/
├── ICM-BUILDER.md            # the universal builder — single source of truth
├── SKILL.md                  # thin wrapper for skill-based agents (Claude Code, Cowork, OpenCode)
├── scripts/
│   └── scan.sh               # read-only codebase scanner (markdown report to stdout)
└── references/               # loaded on demand by the builder, phase by phase
    ├── layer1-patterns.md            # AGENTS.md patterns and anti-patterns
    ├── layer2-patterns.md            # Room CONTEXT.md patterns
    ├── layer3-skills-guide.md        # Writing skill files
    ├── mcp-integration-guide.md      # MCP selection and config
    ├── hooks-guide.md                # Deterministic enforcement (Claude Code/OpenCode)
    ├── self-evaluation-framework.md  # Self-audit rubric
    ├── subagents-guide.md            # When to define subagents
    ├── output-adapters.md            # Per-tool entry file generation
    └── update-mode.md                # Drift detection and patching
```

## What gets generated in YOUR project

```
your-project/
├── AGENTS.md                 # source of truth (icm:managed)
├── CONTEXT.md                # root router — the Silo Rule
├── CLAUDE.md, GEMINI.md, ... # generated copies (never hand-edit)
├── [each room]/CONTEXT.md    # per-folder context
├── .icm/
│   ├── manifest.md           # what ICM manages + scan snapshot (for UPDATE mode)
│   └── self-eval.md          # the agent's done-checking rubric
└── optional: .mcp.json, .claude/ (hooks, skills, agents), opencode.json, .opencode/
```

## Compatibility

| Output | Works with |
|--------|-----------|
| AGENTS.md + CONTEXT.md rooms | Every agent |
| Per-tool entry files | Claude Code, Gemini CLI, Cursor, Copilot, Windsurf |
| MCP config | Claude Code, OpenCode, Cursor, Gemini CLI |
| Skills | Claude Code, Cowork, OpenCode |
| Hooks, subagents | Claude Code, OpenCode |

## License

MIT
