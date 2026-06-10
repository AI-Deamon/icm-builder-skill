# ICM Builder

**Scaffold complete ICM (Interpretable Context Methodology) workspaces for any project.**

An AI agent skill that interviews you about your project, then produces AGENTS.md, root CONTEXT.md, and room CONTEXT.md files — with zero placeholders, real commands, real paths, and project-specific gotchas.

## Install

### One-command install (recommended)

```bash
npx skills add AI-Deamon/icm-builder-skill -g
```

Works across 30+ agent platforms (opencode, Claude Code, Cline, Codex, Gemini, Cursor, Windsurf, and more).

### Manual install

```bash
git clone https://github.com/AI-Deamon/icm-builder-skill.git ~/.agents/skills/icm-builder
```

For opencode specifically, clone to `~/.config/opencode/skills/icm-builder/` instead.

## Usage

Once installed, trigger the skill by asking your AI agent:

- "Set up ICM for my project"
- "Scaffold my context files"
- "Build my AGENTS.md"
- "Create room files for my project"
- "Help me structure this project for Claude"
- "I want to use ICM on this project"

The skill will:

1. **Interview** you about your project (tech stack, work types, gotchas, naming)
2. **Design** the room architecture and get your sign-off
3. **Build** AGENTS.md + CONTEXT.md files with real commands and paths
4. **Optionally** create skill stubs for recurring workflows
5. **Deliver** all files ready to drop into your project root

## Files

```
SKILL.md                        # The skill (loaded by agent on trigger)
references/
├── layer1-patterns.md          # AGENTS.md patterns & anti-patterns
└── layer2-patterns.md          # Room CONTEXT.md patterns & anti-patterns
```

## Requirements

- An AI agent that supports SKILL.md format (opencode, Claude Code, Cline, Codex, Gemini CLI, Cursor, Windsurf, etc.)

## About ICM

Interpretable Context Methodology (ICM) is Jake Van Clief's folder-based system for making any project AI-readable. Instead of dumping everything into one prompt, ICM uses structured markdown files (AGENTS.md + room CONTEXT.md files) to route your AI to the right context for each task — no vector DB, no RAG, no agents.

## License

MIT
