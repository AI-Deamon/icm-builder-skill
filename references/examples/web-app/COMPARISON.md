# Key differences: security-tool vs web-app
# (Read this to understand how ICM adapts)
# ─────────────────────────────────────────────────

## What stays the same
- Three-layer structure (AGENTS.md / root CONTEXT.md / room CONTEXT.md files)
- Room file template (persona, token budget, local map, process, quality bars, hard rules)
- Skill structure (YAML frontmatter, when-to-invoke, protocol, done-when)
- Hook structure (exit codes, stdin JSON, shell scripts)
- Self-evaluation rubric (five dimensions, 25-point scale)

## What changes per project

| Element | Security Pipeline | SaaS Web App |
|---------|------------------|--------------|
| Rooms | 9 (backend, src, Agent, docker, docker/jenkins, docker/postgres, tests, specs, docs) | 5 (api, src, migrations, tests, docs) |
| MCPs | postgres + github + jenkins | postgres + github + linear |
| Hooks | block docker data-destroy, block secret writes | block migration edits, block db:reset |
| Key gotchas | SonarQube false PASS, dual scans module, celery rebuild | Stripe secret mismatch, migration editing |
| Naming | specs/NNN-name/, jenkins overlays | migrations/timestamp_name, ADRs/NNN |
| Primary skills | systematic-debugging, verification-before-completion, pipeline-stage-spec | systematic-debugging, verification-before-completion, db-migration |

## The pattern to internalize

The ICM structure is a constant. The project-specific content — rooms, gotchas, hard rules,
MCP servers, hook conditions — fills the structure. When you answer the Phase 1 interview
honestly and specifically, the skill produces a workspace that reflects your actual project.

The quality of the output = the quality and specificity of the interview answers.
Generic answers → generic workspace → Claude still guesses. Specific answers → specific
workspace → Claude routes correctly every session without being re-taught.
