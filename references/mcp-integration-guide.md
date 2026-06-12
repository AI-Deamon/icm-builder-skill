# MCP Integration Guide

## What MCP is (and what it isn't)

MCP (Model Context Protocol) is connectivity — it gives Claude access to external systems
it cannot reach by reading local files or running local commands.

MCP is NOT:
- A replacement for Skills (which teach processes)
- A replacement for CONTEXT.md (which provides project knowledge)
- Something to add for every external service you use
- Free — a five-server setup can cost 50,000+ tokens upfront

**The rule:** Add MCP when Claude needs to reach a system. Don't add it when Claude can get
the information from local files, git history, or bash commands.

---

## Decision: MCP vs. not

| Claude needs to... | Use MCP? | Alternative |
|-------------------|----------|-------------|
| Read live database records | Yes | — |
| Open/comment on GitHub PRs | Yes | — |
| Fetch issue details from Linear/Jira | Yes | — |
| Read Jenkins build logs | Yes | — |
| Read local source files | No | Native Read tool |
| Run tests | No | Native Bash tool |
| Read git history | No | `Bash(git:*)` |
| Read environment variables | No | `.env` file in context |

---

## .mcp.json — shared team config (committed to repo)

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${env:GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "type": "stdio",
      "command": "uvx",
      "args": ["postgres-mcp", "--read-only"],
      "env": {
        "DATABASE_URL": "${env:DATABASE_URL}"
      }
    },
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app/sse"
    },
    "sentry": {
      "type": "http",
      "url": "https://mcp.sentry.io/sse"
    }
  }
}
```

**Critical**: A misplaced comma silently disables every server. Lint the JSON after editing.
`cat .mcp.json | python3 -m json.tool` — should print clean JSON with no errors.

---

## ~/.claude.json — personal config (not committed)

For secrets and personal tokens that shouldn't be in the repo:

```json
{
  "mcpServers": {
    "github-personal": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_personal_token_here"
      }
    }
  }
}
```

---

## MCP server catalogue — production-proven servers

### GitHub (official, recommended)
```bash
claude mcp add github \
  --command npx \
  --args "-y @modelcontextprotocol/server-github" \
  --env GITHUB_TOKEN=your_token
```
What it enables: list/create/comment on PRs and issues, search code, get file contents
Access pattern: read-write by default — scope with a fine-grained token if you want read-only

### PostgreSQL (community, widely used)
```bash
claude mcp add postgres \
  --command uvx \
  --args "postgres-mcp --read-only" \
  --env DATABASE_URL=postgresql://user:pass@host/db
```
What it enables: SQL queries, schema inspection, EXPLAIN plans
Access pattern: `--read-only` flag enforced — do not omit it for production databases

### Linear (official remote)
```json
{
  "linear": {
    "type": "http",
    "url": "https://mcp.linear.app/sse"
  }
}
```
What it enables: read/write issues, projects, cycles
Access pattern: authenticates via Linear OAuth — first use prompts login

### Sentry (official remote)
```json
{
  "sentry": {
    "type": "http",
    "url": "https://mcp.sentry.io/sse"
  }
}
```
What it enables: error groups, stack traces, releases, breadcrumbs
Access pattern: read-only by default

### Slack (official remote)
```json
{
  "slack": {
    "type": "http",
    "url": "https://mcp.slack.com/sse"
  }
}
```
What it enables: search messages, post to channels, read canvas
Note: workspace admin must approve MCP integration before users can connect

### Playwright (Microsoft official)
```bash
claude mcp add playwright \
  --command npx \
  --args "@playwright/mcp"
```
What it enables: browser automation, screenshots, form interaction, visual testing
Access pattern: full browser control — scope with care

### Jenkins (community)
Varies by instance. Typically:
```json
{
  "jenkins": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "jenkins-mcp-server"],
    "env": {
      "JENKINS_URL": "http://localhost:8080",
      "JENKINS_USER": "admin",
      "JENKINS_TOKEN": "${env:JENKINS_TOKEN}"
    }
  }
}
```
What it enables: build logs, job status, trigger builds

---

## MCP in room CONTEXT.md files

When a room uses an MCP server, document it in that room's CONTEXT.md:

```markdown
## 8. MCP Servers Available in This Room

| Server | Access | Use for |
|--------|--------|---------|
| `postgres` | read-only | Verify migration results, debug data issues |
| `github` | read-write | Create PRs, fetch PR diffs for review |
```

Also add the MCP tool names to the relevant skill's `allowed-tools`:
```yaml
allowed-tools: Read Bash(git:*) mcp__github__get_pull_request_files mcp__github__create_review
```

MCP tool names follow the pattern: `mcp__[server-name]__[tool-name]`

---

## Token cost management

MCP servers are expensive — their tool schemas load upfront.

| Server count | Approximate token cost |
|--------------|----------------------|
| 1 server | ~5,000–10,000 tokens |
| 3 servers | ~20,000–35,000 tokens |
| 5 servers | ~50,000+ tokens |

**Strategy:** Pin only the MCP servers the project actually needs. Write thin Skills that
orchestrate the MCP calls — Skills add ~50 tokens until invoked; MCPs add tokens always.

If a team member only needs GitHub and Postgres: configure just those two.
Don't add every possible integration speculatively.

---

## Referencing MCP tools in Skills

```yaml
---
name: pr-review
description: Use when reviewing a pull request or asked to check code before merge.
allowed-tools: Read Bash(git:*) mcp__github__get_pull_request_files mcp__github__create_pending_pull_request_review mcp__github__submit_pull_request_review
---
```

The `allowed-tools` field limits which MCP tools this skill can call. This prevents a
docs-formatting skill from accidentally having access to GitHub write operations.

---

## Anti-patterns

| Anti-pattern | Fix |
|--------------|-----|
| Adding MCP for info available in local files | Use native Read tool instead |
| Five+ MCP servers for a project that needs two | Remove unused servers |
| Production database without `--read-only` | Always use read-only for prod |
| Personal tokens in `.mcp.json` (committed) | Move to `~/.claude.json` (not committed) |
| Not scoping MCP tools in skill allowed-tools | Add explicit tool list to each skill |
| Misplaced comma in .mcp.json | Lint with `python3 -m json.tool` before saving |
