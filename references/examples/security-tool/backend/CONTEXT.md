# ─────────────────────────────────────────────────
# backend/CONTEXT.md
# ─────────────────────────────────────────────────

# CONTEXT.md — backend/

**Last updated**: 2026-06-12
**Location**: `backend/` at repo root
**Layer**: 2 (Distributed)

## 1. Room Definition

**Persona**: FastAPI / Celery Engineer
**Objective**: Ship backend services, scan APIs, and async task pipelines. Touch only this
folder unless types or schemas cross the frontend boundary.

## 2. Token Budget

| Task | Load | Skip |
|------|------|------|
| Add a scan API endpoint | `app/api/scans/`, `app/schemas/`, `app/models/` | `src/`, `docker/jenkins/`, `specs/` |
| Wire a Celery task | `app/core/celery_app.py`, `app/tasks/`, `app/services/scan_orchestrator.py` | `src/`, `app/api/auth.py` |
| Fix a parser bug | `app/services/reporting/parsers/`, `app/services/reporting/cross_ref.py` | `app/api/`, `src/` |
| Update DB models | `app/models/`, `app/core/db.py` | `src/`, `docker/` |
| Add a service module | `app/services/`, `app/api/` | `src/`, `app/core/celery_app.py` (read-only) |
| Fix a callback handler | `app/api/scans/`, `app/schemas/scan.py` | `src/`, `docker/`, `specs/` |
| Generate frontend types | `scripts/generate-frontend-types.py`, `app/schemas/` | `src/`, `docker/` |

## 3. Local Map

```
backend/
├── app/
│   ├── api/            # FastAPI routers (auth, scans, reports, projects, users)
│   ├── services/       # Business logic
│   │   ├── scan_orchestrator.py
│   │   ├── jenkins_service.py
│   │   └── reporting/ # parsers/, cross_ref.py, report_builder.py
│   ├── core/           # config.py, db.py, celery_app.py, security.py
│   ├── models/         # SQLAlchemy ORM models
│   ├── schemas/        # Pydantic request/response models
│   ├── tasks/          # Celery task modules (imported via celery_app.py)
│   ├── websockets/     # Real-time scan progress push
│   └── main.py         # FastAPI entrypoint
├── requirements.txt
└── Dockerfile
```

**Warning**: `backend/app/api/scans.py` (file) and `backend/app/api/scans/` (directory) both
exist. Python resolves imports to the file. Migration is incomplete.

## 4. The Process

1. **Source** — read the relevant `app/` module + `app/core/celery_app.py` if wiring tasks
2. **Plan** — draft function signature (Pydantic models, task decorator, retry policy) and
   list all callers that will be affected
3. **Execute** — write the module; update `celery_app.py` imports if a task moved; add pytest
4. **Refine** — `pytest tests/ -v`; rebuild `celery_worker` alongside `backend`;
   `python run.py staging` to verify full stack

## 5. What Good Looks Like

- ≥80% pytest coverage on new endpoints. All functions type-hinted (no `Any`).
- Every new endpoint has at least one success + one failure test via `TestClient`.
- Celery tasks have explicit `max_retries` and `default_retry_delay` set.
- All imports start from `app.` (absolute). No relative imports across modules.
- No `# type: ignore` without a linked ticket number in the comment.

## 6. Constraints

- **API surface**: Do not expose internal ORM models as response schemas. Always use Pydantic views.
- **SonarQube retry**: Do not remove the 3-attempt retry loop in `fetch_sonar_issues()`. ES index
  lag after container restart causes false-empty reports without it.
- **Stuck scans**: Do not let a scan stay `RUNNING`. DB constraint `ix_scans_project_state` blocks
  new scans. Use the force-unlock endpoint to recover.
- **Callback token**: Do not skip `CALLBACK_TOKEN` validation in production. Test env skips it;
  prod must match exactly or callbacks are silently dropped.
- **SonarQube exit code**: Do not trust exit code 0 as success. Verify `findings.count > 0` in
  the callback handler — zero findings with exit 0 means the JS/TS sensor silently failed.

## 7. Skills Available in This Room

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `/systematic-debugging` | Test fails or unexpected behaviour | Forces hypothesis-first debugging |
| `/verification-before-completion` | Before any PR or "done" claim | Lint + test + build gate |

## 8. MCP Servers Available in This Room

| Server | Access | Use for |
|--------|--------|---------|
| `postgres` | read-only | Verify migration results, debug scan state, check data issues |

## 9. Hard Rules

- **Thou shalt NOT edit `scans.py` as a module.** `scans/` directory exists; Python resolves
  to the file. Editing the wrong one silently breaks all scan-related imports.
- **Thou shalt NOT rebuild `backend` without also rebuilding `celery_worker`.** The worker runs
  `process_scan_reports_task`. Without a rebuild, stale task code runs and reports are wrong.
- **Thou shalt NOT hardcode the SonarQube token.** It lives in backend env only. Hardcoding
  commits it to git and invalidates it on rotation.
- **Thou shalt NOT rename a Celery task without updating `app/core/celery_app.py`.** Imports are
  explicit — a renamed task that isn't updated there will fail silently at runtime.
