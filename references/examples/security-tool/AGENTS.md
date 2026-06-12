# Example: Security Pipeline Project
# Project type: Full-stack security scanning pipeline
# Stack: React 19/TypeScript + FastAPI + Celery + Jenkins + Docker + SonarQube + Kali
#
# This is the AGENTS.md this project would produce.
# ─────────────────────────────────────────────────

# AGENTS.md

Archer — DevSecOps security scanning pipeline: React 19/TypeScript frontend + FastAPI backend + Jenkins CI/CD + SonarQube + Kali Linux tooling.

## Commands

### Frontend
```bash
npm install
npm run dev              # Vite on :5173, proxies /api → localhost:8000
npm run build            # tsc -b && vite build (typechecks before build)
npm run lint             # ESLint
npx vitest run           # All frontend tests
npx vitest run src/tests/pages/LoginPage.test.tsx  # Single test
```

### Backend
```bash
pip install -r backend/requirements.txt
pytest tests/ -v                                         # All backend tests
pytest tests/test_integration.py::test_integration_v1   # Single test
```

### Docker
```bash
python run.py dev        # Foreground, hot-reload — preserves data
python run.py test       # Background, isolated DB, mocked execution
python run.py staging    # Background, real Jenkins/Kali — preserves data
python run.py down       # DESTROYS ALL POSTGRES DATA — use only to reset
```

### Default staging login
`admin` / `admin123` at http://localhost:5173

## Architecture

| Layer | Path | Notes |
|-------|------|-------|
| Frontend | `src/` | React Router + TanStack Query, lazy-loaded pages |
| Backend | `backend/app/` | FastAPI, SQLAlchemy, Celery + Redis |
| Backend tests | `tests/` | conftest.py adds backend/ to sys.path |
| Frontend tests | `src/tests/` | Vitest + jsdom |
| Jenkins pipeline | `Agent/` | Separate Git repo — Jenkinsfile is the only artifact |
| Docker compose | `docker/` | Base + dev/test/staging overlays |
| Jenkins image | `docker/jenkins/` | 134 plugins, pins jenkins/jenkins:2.541.3 |
| Postgres image | `docker/postgres/` | initdb.d/ runs only on first fresh volume |
| Specs | `specs/` | NNN-feature-name/ pattern |
| Docs | `docs/` | Reference only — never authoritative for behaviour |

## Routing Table

| User intent | Room | Read |
|-------------|------|------|
| Add or fix backend endpoint, Celery task, or parser | `backend/` | `backend/CONTEXT.md` |
| Fix UI bug, add page or component | `src/` | `src/CONTEXT.md` |
| Edit Jenkinsfile, pipeline stage, or callback | `Agent/` | `Agent/CONTEXT.md` |
| Edit docker-compose, Dockerfile, or service wiring | `docker/` | `docker/CONTEXT.md` |
| Build or configure Jenkins container image | `docker/jenkins/` | `docker/jenkins/CONTEXT.md` |
| Configure Postgres image or init scripts | `docker/postgres/` | `docker/postgres/CONTEXT.md` |
| Add or run pytest | `tests/` | `tests/CONTEXT.md` |
| Write spec, plan, or tasks for a feature | `specs/` | `specs/CONTEXT.md` |
| Read architecture or reference docs | `docs/` | `docs/CONTEXT.md` |

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Feature spec folder | `specs/NNN-feature-name/` | `specs/007-sonarqube-upgrade/` |
| Spec document | `specs/NNN-name/spec.md` | `specs/007-sonarqube-upgrade/spec.md` |
| Frontend test | `src/tests/[area]/[Page].test.tsx` | `src/tests/pages/LoginPage.test.tsx` |
| Backend test | `tests/test_[module].py` | `tests/test_scan_orchestrator.py` |
| Versioned build artifact | `[name]-v[N].[ext]` | `report-v2.pdf` |
| Docker overlay | `docker/docker-compose.[env].yml` | `docker/docker-compose.staging.yml` |

## Gotchas

- **Dual scans module**: `backend/app/api/scans.py` AND `backend/app/api/scans/` both exist. Python resolves imports to the file. Never import from `scans/` — it silently fails or raises ImportError.
- **Celery rebuild**: Rebuilding `backend` without also rebuilding `celery_worker` leaves stale task code running. Always rebuild both: `--no-deps backend celery_worker`.
- **`python run.py down` destroys data**: Runs `docker compose down --volumes`. All Postgres data (scans, reports, projects) is gone. Use env-specific restart commands instead.
- **SonarQube false PASS**: SonarScanner exits 0 with zero findings when JS/TS/CSS analysis silently fails (Node.js v24 PostCSS crash). Verify `findings.count > 0`, not just exit code.
- **SonarQube silent death**: Container can die without obvious logs. If findings=0 on callback, check `docker ps` and restart with `up -d --no-deps sonarqube`.
- **One active scan per project**: DB constraint `ix_scans_project_state` blocks new scans if one is stuck RUNNING. Use force-unlock endpoint.
- **Callback token**: Test env skips validation. Prod must match `CALLBACK_TOKEN` exactly — mismatch silently drops callbacks.
- **Nginx staging 403**: Do not mount `../dist:/usr/share/nginx/html:ro` in staging — Dockerfile bakes the frontend. The mount shadows the built files.

## Style

- **Imports**: external → internal → types. Use `import type` for TypeScript types.
- **Backend**: all imports from `app.` (absolute). Type hints required. No `Any`. `snake_case`.
- **Frontend**: pages = default export. Components = named export + `memo()` + arrow functions.
- **Types**: centralized in `src/types.ts` — never inline types in pages.
- **Files**: max 300 lines. Split by single responsibility.
- **Verify before done**: `npm run lint && npm run build && npx vitest run && pytest tests/`

## Self-Evaluation
Before marking any task done, run `.claude/self-eval.md`.
Score ≥ 18 = done. Score < 13 = restart with /clear.
