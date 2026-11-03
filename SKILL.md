---
name: icm-builder
version: 1.0.0
description: >
  Builds and maintains an Interpretable Context Methodology (ICM) workspace for any
  codebase: root AGENTS.md, per-folder CONTEXT.md room files, tooling rules that tell
  agents when to use skills/MCPs instead of wasting tokens on grep/glob searches, plus
  MCP config, hooks, skills, self-eval rubric, and per-tool entry files (CLAUDE.md,
  GEMINI.md, .cursor/rules, Copilot). Scans the codebase first, asks only what it can't
  infer, and supports UPDATE mode to fix drift in an existing ICM workspace. Use this
  skill whenever the user wants to set up, scaffold, rebuild, or update project context
  for AI agents — trigger on "set up ICM", "create AGENTS.md", "create CLAUDE.md or
  GEMINI.md", "make my repo AI-readable", "help the agent understand my project",
  "context files", "room files", "my agent keeps losing context", "stop wasting tokens
  searching", "onboard Claude/Gemini/Cursor to this codebase", or when a user describes
  a project and wants persistent, session-independent agent context — even if they
  never say "ICM".
---

# ICM Builder

This skill is a thin wrapper. The complete builder logic lives in `ICM-BUILDER.md` in
this skill's directory — it is model-agnostic and shared with users of other agents
(OpenCode, Gemini CLI, Cursor), so all behavior is defined there, in one place.

## What to do

1. Read `ICM-BUILDER.md` (same directory as this file) and execute it phase by phase.
2. Start with Phase 0 (mode detection: FRESH vs UPDATE), then Phase 1 (run
   `scripts/scan.sh` on the project root — fall back to the manual scan steps if the
   shell is unavailable).
3. Read files under `references/` only at the phase that calls for them.

## Environment notes

- **Claude Code**: full support — write all files directly into the repo, including
  `.claude/` hooks, skills, and subagents.
- **Cowork**: you can generate every file, but only into a folder the user has connected.
  If no project folder is connected, request one before scanning.
- **OpenCode**: reads `AGENTS.md` natively; place generated skills in
  `.opencode/skill/` and MCP config in `opencode.json` as ICM-BUILDER.md Phase 7 describes.
- **No shell available**: skip `scan.sh`, use the manual scan checklist in Phase 1.
