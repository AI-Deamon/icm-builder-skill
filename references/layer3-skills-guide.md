# Layer 3 Skills Guide

## What a skill is

A skill is a directory at `.claude/skills/[skill-name]/` containing a required `SKILL.md`
and optional helper files. When Claude sees a relevant task, it loads the skill body into
context and follows the instructions inside.

**Progressive disclosure cost:**
- Session start: ~30-50 tokens (name + description only)
- Skill invoked: ~5,000 tokens (full body)
- Helper files referenced: loaded on demand

This means 50 skills installed = ~2,500 tokens overhead. Cheap. Use many skills.

---

## SKILL.md frontmatter — exact spec

```yaml
---
name: skill-name          # Required. Max 64 chars. Lowercase, digits, hyphens only.
                          # NEVER use "anthropic" or "claude" — reserved, will fail to load.
description: >
  Use when [specific trigger condition]. [What this skill does in one sentence].
  [Optional: what it does NOT do, to prevent over-triggering.]
allowed-tools: Read Bash(git:*) mcp__github__get_pull_request_files
               # Optional. Space-delimited. Scopes the tool surface for this skill.
               # Use it — a docs skill has no business with GitHub write tools.
---
```

**The description field is the most important.** Claude decides whether to load the skill
based on it. Write it as "Use when [X]" — specific, not generic.

Bad: `description: Helps with code quality`
Good: `description: Use when reviewing a pull request or asked to check code quality before a merge. Pulls the diff, checks against project conventions, and produces inline feedback. Does not auto-approve — always leaves final decision to the human.`

---

## Skill body structure

```markdown
# [Skill Name]

## When to invoke
[Specific trigger phrases and conditions — what the user says or what situation arises]
[Also: when NOT to invoke — prevents over-triggering]

## Protocol
1. [Step 1 — concrete, not vague]
2. [Step 2]
[...]
N. [Final verification step — must produce a pass/fail signal]

## Done when
[Clear, observable completion criteria]
[What Claude must be able to show as evidence of completion]
```

Keep the body under 500 lines. For anything longer, create adjacent files and reference them:
- `SKILL.md` — core instructions
- `checklist.md` — detailed checklist Claude reads when running the skill
- `examples.md` — examples of good/bad output
- `reference.md` — background info Claude loads on demand

---

## allowed-tools — scope the tool surface

Use `allowed-tools` as defence-in-depth. A skill's tool scope should match what it actually
needs and nothing more.

| Skill type | Appropriate tools |
|------------|------------------|
| Code review | `Read Bash(git:*) mcp__github__*` |
| Debugging | `Read Bash` |
| Documentation | `Read Write` |
| Database query | `mcp__postgres__query` |
| Test runner | `Bash` |
| File organiser | `Read Write Bash(find:*) Bash(mv:*)` |

Bash can be scoped: `Bash(git:*)` allows only git commands. `Bash(npm:*)` allows only npm.

---

## Skill vs. other mechanisms — decision table

| The need | Use | Why |
|----------|-----|-----|
| Claude keeps forgetting a multi-step process | Skill | Text in context, loaded when relevant |
| Something MUST happen every time | Hook | Deterministic, cannot be forgotten |
| Claude needs to reach an external system | MCP | Connectivity layer |
| Task needs isolated context window | Subagent | Prevents context contamination |
| Guidance requires situational judgment | CONTEXT.md | Advisory, not mandatory |

**The rule:** If "Claude forgot" is an acceptable failure mode → CONTEXT.md or Skill.
If "Claude forgot" is a blocking failure → Hook.

---

## Skill placement — where skills live

Three locations, in priority order:

| Location | Path | Scope | When to use |
|----------|------|-------|-------------|
| Project | `.claude/skills/[name]/SKILL.md` | This repo only | Team standards, project-specific workflows |
| Personal | `~/.claude/skills/[name]/SKILL.md` | All your projects | Personal preferences, shortcuts |
| Plugin marketplace | `/plugin marketplace add owner/repo` | Installed | Community-maintained skills |

Commit project skills to the repo — they're team standards, not personal config.

---

## Auto-trigger vs. manual invocation

Skills auto-trigger when Claude detects a relevant task based on the description.
Skills can also be invoked manually with `/[skill-name]`.

**Auto-trigger works when** the description is specific and unambiguous.
**Manual-only skills** (add `<!--manual-only-->` comment) — use when auto-trigger creates
noise (e.g., a migration skill that should only run when explicitly requested).

```yaml
---
name: db-migration
description: >
  Use ONLY when explicitly asked to run a database migration. Do not auto-trigger
  on general database work. <!-- manual-only -->
---
```

---

## Common skill patterns for dev projects

### Debugging protocol
```yaml
name: systematic-debugging
description: Use when a test fails or behaviour is unexpected. Forces hypothesis-first debugging.
allowed-tools: Read Bash(cat:*) Bash(grep:*) Bash(find:*)
```

### Pre-completion verification
```yaml
name: verification-before-completion
description: Use before saying done, before any PR, or when asked "is this ready?".
allowed-tools: Bash
```

### Spec writing
```yaml
name: spec-writer
description: Use when planning a new feature, designing an API, or asked to write a spec.
allowed-tools: Read Write
```

### Code review
```yaml
name: code-review
description: Use when reviewing a PR or asked for feedback on a diff.
allowed-tools: Read Bash(git:*) mcp__github__get_pull_request_files mcp__github__create_pending_pull_request_review
```

### Database query
```yaml
name: db-query
description: Use when asked to check live data, debug a data issue, or validate migration results.
allowed-tools: mcp__postgres__query
```

---

## Anti-patterns

| Anti-pattern | Fix |
|--------------|-----|
| Skill body over 500 lines | Move detail to adjacent files, reference from body |
| Generic description ("helps with coding") | Rewrite with "Use when [X]" and specific triggers |
| No allowed-tools | Add scope — a skill with no scope can use any tool |
| Steps that say "fix the issue" | Replace with concrete actions and verification commands |
| No "Done when" section | Add it — Claude needs a clear completion signal |
| Skill doing what a hook should | Move blocking/mandatory behaviour to a hook |
