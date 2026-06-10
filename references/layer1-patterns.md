# Layer 1 Patterns — AGENTS.md

## What AGENTS.md is for

AGENTS.md is a navigation file, not a project brief. Its only jobs are:
1. Tell Claude what this project is (one sentence)
2. Tell Claude what commands to run
3. Tell Claude where things live (architecture table)
4. Tell Claude which room to go to for which task (routing table)
5. Encode the gotchas that would burn a new developer

Everything else belongs in a room CONTEXT.md.

---

## The routing table — most important pattern

This is the single highest-leverage addition most projects are missing. Without it, Claude
guesses which context files to read and often gets it wrong. With it, every task routes
cleanly on the first try.

### Good routing table

```markdown
## Routing Table

| User intent | Room | Context file |
|-------------|------|--------------|
| Add or fix backend endpoint | `backend/` | `backend/CONTEXT.md` |
| Fix UI bug or add component | `src/` | `src/CONTEXT.md` |
| Edit Jenkinsfile or pipeline | `Agent/` | `Agent/CONTEXT.md` |
| Write spec or plan | `specs/` | `specs/CONTEXT.md` |
| Edit docker-compose or infra | `docker/` | `docker/CONTEXT.md` |
| Run or add pytest | `tests/` | `tests/CONTEXT.md` |
| Read reference docs | `docs/` | `docs/CONTEXT.md` |
```

Why this works: Claude reads the table, matches the task description, teleports to that room.
One step. No archaeology.

### Bad routing table

```markdown
| Code | /src | CONTEXT.md |
| Docs | /docs | CONTEXT.md |
```

Why this fails: "Code" matches everything. Claude still has to guess what "code" means in
context of the actual task.

**Use real intent phrases** — the kind of thing a developer would actually type. Not category
names.

---

## Naming conventions — second most important

Without naming conventions, Claude invents its own names and puts files wherever it wants.
With naming conventions, Claude knows exactly where to look and what to call things — without
a database, without a vector store, just a lookup table.

### Good naming conventions

```markdown
## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Feature spec | `specs/NNN-feature-name/spec.md` | `specs/007-sonarqube-upgrade/spec.md` |
| Spec plan | `specs/NNN-feature-name/plan.md` | `specs/007-sonarqube-upgrade/plan.md` |
| Draft note | `draft-[topic].md` | `draft-auth-flow.md` |
| Final note | `[topic].md` | `auth-flow.md` |
| Versioned output | `[name]-v[N].[ext]` | `report-v2.pdf` |
| Test file | `test_[module].py` | `test_scan_orchestrator.py` |
```

Why this works: Claude can find `demo_v2` without reading every file in the directory. It
knows which folder `test_scan_orchestrator.py` belongs in. It knows `draft-` means WIP.

### Bad naming conventions

```markdown
## Naming Conventions
- Use descriptive names
- Keep files organized
```

Why this fails: Means nothing. Claude already tries to do this by default.

---

## Architecture table — keep it honest

The architecture table tells Claude where layers live. It is not an org chart or a feature
list. It is a path map.

### Good architecture table

```markdown
## Architecture

| Layer | Path | Notes |
|-------|------|-------|
| Frontend | `src/` | React Router pages + TanStack Query |
| Backend | `backend/app/` | FastAPI, SQLAlchemy, Celery |
| Backend tests | `tests/` | conftest.py adds backend/ to sys.path |
| Frontend tests | `src/tests/` | Vitest + jsdom |
| Jenkins pipeline | `Agent/` | Separate Git repo, Jenkinsfile only |
| Docker | `docker/` | Base compose + dev/test/staging overlays |
| AI context | `.ai/` | Architecture docs, gotchas, constraints |
```

### Bad architecture table

```markdown
| Frontend | /src | React |
| Backend | /api | Python |
```

Why bad: Paths without leading slash are ambiguous. "React" tells Claude nothing about what
pattern to follow. Missing the test paths means Claude puts tests in the wrong place.

---

## Gotchas — be specific or don't bother

Generic gotchas ("be careful with database migrations") teach Claude nothing it doesn't
already know. Specific gotchas ("there are two scans modules: `scans.py` and `scans/` —
Python resolves to the file, not the directory") prevent real failures.

### What makes a good gotcha

A good gotcha has three parts:
1. The trap (what looks reasonable but isn't)
2. The consequence (what happens when you fall in)
3. The escape (what to do instead)

```markdown
## Gotchas

- **Dual scans module**: Both `backend/app/api/scans.py` AND `backend/app/api/scans/` exist.
  Python imports resolve to `scans.py` (the file), not the directory. Never import from
  `scans/` — it silently fails or causes an import error.

- **Celery rebuild**: Rebuilding `backend` without also rebuilding `celery_worker` leaves the
  old task code running. Always rebuild both together.

- **`python run.py down` destroys data**: This runs `docker compose down --volumes` which
  wipes all Postgres data. Only use it when you intend to start from scratch.
```

---

## Length discipline

AGENTS.md should fit on one screen. If it doesn't, you've put context in the wrong place.

| Too long | Fix |
|----------|-----|
| Detailed explanation of how the auth system works | Move to `backend/CONTEXT.md` |
| Full list of environment variables | Move to `docs/` or room CONTEXT.md |
| Explanation of the database schema | Move to `docs/` |
| Style guide paragraphs | Compress to bullet list |

The routing table, architecture table, commands, and gotchas: that's it.
Everything else belongs in a room.

---

## Anti-patterns to avoid

| Anti-pattern | Why it fails |
|--------------|--------------|
| AGENTS.md over 80 lines | Claude burns tokens reading irrelevant context on every task |
| No routing table | Claude guesses; sometimes right, often wrong |
| Generic gotchas | Claude ignores them because they match too many situations |
| Routing table with category names ("Code", "Docs") | Too vague to route reliably |
| File paths without confirmation | Claude navigates to paths that don't exist |
| Commands that need environment setup not mentioned | Commands fail silently |
