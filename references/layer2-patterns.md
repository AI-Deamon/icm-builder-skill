# Layer 2 Patterns — Room CONTEXT.md Files

## What a room CONTEXT.md is for

A room CONTEXT.md is the onboarding doc for a single type of work. When Claude drops into
a room, it reads this file and nothing else (unless the token budget says otherwise). The
file must answer four questions:

1. What kind of work happens here?
2. What files should I read for this specific task?
3. What is the process I should follow?
4. What must I never do?

---

## The persona — set the role immediately

The persona is not "you are an AI assistant". It is a real engineering role. It tells Claude
what expertise to embody, what vocabulary to use, and what tradeoffs to optimise for.

### Good personas

```
FastAPI / Celery Engineer
React 19 / TypeScript Engineer
Jenkins Pipeline Engineer
Docker Compose / Infrastructure Engineer
Solutions Architect
pytest / Integration Test Engineer
```

### Bad personas

```
AI coding assistant
Helpful developer
Code writer
```

Why bad: "Code writer" doesn't tell Claude whether to use async patterns, whether to care
about migration order, or whether type hints are required. A specific role implies all of that.

---

## The token budget — most important section in the room file

This is the table that prevents Claude from reading everything. Every row is a task + what to
load + what to explicitly skip.

The skip column is just as important as the load column. Without an explicit skip list, Claude
might load the frontend files while working on the backend. The skip list prevents this.

### Good token budget

```markdown
## 2. Token Budget

| Task | Load | Skip |
|------|------|------|
| Add a scan API endpoint | `app/api/scans/`, `app/schemas/`, `app/models/` | `src/`, `docker/jenkins/`, `specs/` |
| Wire a Celery task | `app/core/celery_app.py`, `app/tasks/`, `app/services/scan_orchestrator.py` | `src/`, `app/api/auth.py` |
| Fix a parser bug | `app/services/reporting/parsers/`, `app/services/reporting/cross_ref.py` | `app/api/`, `src/` |
| Update DB models | `app/models/`, `app/core/db.py` | `src/`, `docker/` |
```

Why this works: Every task has a bounded read scope. Claude never reads the frontend while
fixing a backend parser bug. Token cost stays predictable.

### Bad token budget

```markdown
| Task | Load | Skip |
|------|------|------|
| Backend work | backend/ | frontend/ |
| Frontend work | src/ | backend/ |
```

Why bad: "Backend work" is too vague. Claude loads the entire backend folder for every task,
including files irrelevant to the specific task.

**Granularity rule**: Each row should represent a specific task type, not a category. If you
find yourself writing "backend work", split it into "add endpoint", "fix parser", "update model".

---

## The local map — be honest about structure

The local map tells Claude what's in this room without it having to explore. Use the actual
directory structure. Don't invent paths.

### Good local map

```
backend/
├── app/
│   ├── api/            # FastAPI routers (auth, scans, reports, projects)
│   ├── services/       # Business logic (scan_orchestrator, jenkins_service, reporting/)
│   ├── core/           # config, db, celery_app, security
│   ├── models/         # SQLAlchemy ORM
│   ├── schemas/        # Pydantic request/response models
│   ├── tasks/          # Celery task definitions
│   └── main.py         # FastAPI entrypoint
├── requirements.txt
└── tests/              # pytest — NOT in src/tests/
```

Notes in the map are valuable. "NOT in src/tests/" prevents a real mistake. "FastAPI routers"
tells Claude what kind of code lives there.

### Bad local map

```
backend/
├── src/
├── tests/
└── config/
```

Why bad: No notes. Claude doesn't know what pattern each folder follows. "src/" inside a
Python project is unusual and warrants a note.

---

## The process — concrete steps with real commands

The process is the workflow Claude should follow when working in this room. It must end with
a real verification step — the actual command that proves the work is correct.

### Good process

```markdown
## 4. The Process

1. **Source** — read the relevant `app/` module + `app/core/celery_app.py` if wiring tasks
2. **Plan** — draft the function signature, Pydantic models, task decorator, retry policy
3. **Execute** — write the module; update celery_app.py imports if task moved; add pytest
4. **Refine** — `pytest tests/ -v`; rebuild `celery_worker` alongside `backend`;
   full stack bring-up via `python run.py staging`
```

Why this works: Step 4 is real. A developer can follow it. "pytest tests/ -v" will either
pass or fail — there's no ambiguity.

### Bad process

```markdown
1. Read the code
2. Make changes
3. Test it
4. Done
```

Why bad: "Test it" tells Claude nothing. Which test command? Against which test database?
With which environment variables?

---

## What good looks like — measurable quality bars

This section sets the quality standard for this room's output. It should be measurable or
observable — not aspirational.

### Good quality bars

```markdown
## 5. What Good Looks Like

- ≥80% pytest coverage on new endpoints. All functions type-hinted (no `Any`).
- Every new endpoint has at least one success + one failure test via TestClient.
- Celery tasks have explicit retry policies. All imports start from `app.`.
- No `# type: ignore` without a ticket number in the comment.
```

### Bad quality bars

```markdown
- Code is clean and readable
- Tests pass
- Good coverage
```

Why bad: "Clean and readable" is subjective. "≥80% coverage" is not. Claude can check one
but not the other.

---

## Hard rules — consequences matter

A hard rule without a consequence is advice. A hard rule with a consequence is a guardrail.

### Good hard rules

```markdown
## 7. Hard Rules

- **Thou shalt NOT edit `scans.py` as a module.** The directory `scans/` exists and Python
  resolves imports to the file. Editing `scans/` files directly silently breaks imports.

- **Thou shalt NOT rebuild `backend` without `celery_worker`.** The worker runs
  `process_scan_reports_task`. Without rebuilding it, the old task code runs and reports
  contain stale data.

- **Thou shalt NOT hardcode the SonarQube token.** It lives in backend env only. Hardcoding
  it causes it to be committed to git and invalidated on rotation.
```

### Bad hard rules

```markdown
- Don't break things
- Always write tests
- Be careful with the database
```

Why bad: "Be careful with the database" does not tell Claude what careful looks like.

---

## Skill triggers — name them specifically

If a room has recurring workflows that go beyond simple edits — debugging, review,
deployment — name them as skill triggers. A skill trigger tells Claude to switch into a
named process rather than improvising.

### Good skill triggers

```markdown
## 7. Mandatory Skill Triggers

- A pytest case fails → trigger `systematic-debugging` (state a hypothesis before editing)
- All endpoints of a feature complete → trigger `verification-before-completion`
- Celery task signature changes → trigger `requesting-code-review` before merge
- DB migration needed → trigger `dispatching-parallel-agents` (migration + test in parallel)
```

### When to add skill triggers

Add a skill trigger when:
- The task is multi-step and Claude tends to skip steps
- The task requires checking work before moving forward
- The task affects other people (code review, API contract changes)
- The task is risky (migrations, deploys, version upgrades)

Don't add skill triggers for normal development work — they create noise.

---

## The Last Updated line — underrated

Add `**Last updated**: [date]` at the top of every CONTEXT.md. When you open a room file
and see it was last updated three months ago while the codebase has been active, you know
to review it before trusting it. This one line saves significant debugging time.

---

## Anti-patterns to avoid

| Anti-pattern | Why it fails |
|--------------|--------------|
| Token budget with only 2-3 rows | Too coarse; Claude still loads too much |
| No skip column in token budget | Claude might still read cross-room files |
| Process steps without verification commands | Claude declares done before verifying |
| Hard rules without consequences | Treated as suggestions, ignored under pressure |
| Quality bars that are subjective | Claude can't check them and defaults to "looks good" |
| Generic persona ("helpful assistant") | No expertise context; outputs feel generic |
| Local map with invented paths | Claude navigates to files that don't exist |
