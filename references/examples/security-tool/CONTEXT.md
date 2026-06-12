# ─────────────────────────────────────────────────
# Root CONTEXT.md for the security-tool example
# ─────────────────────────────────────────────────

# CONTEXT.md

## The Silo Rule

Archer is siloed by work type. Drop into the correct room, read its CONTEXT.md, execute.
Never load files from Room A while working in Room B.
`AGENTS.md` is the only always-loaded file. Each room defines its own load/skip budget.

## Intent → Room Routing

| If the user wants to... | Go to | Read |
|-------------------------|-------|------|
| Add scan endpoint, fix parser, wire Celery task | `backend/` | `backend/CONTEXT.md` |
| Fix UI bug, add page, component, or hook | `src/` | `src/CONTEXT.md` |
| Edit Jenkinsfile or pipeline stage | `Agent/` | `Agent/CONTEXT.md` |
| Edit compose, Dockerfile, network, or volume | `docker/` | `docker/CONTEXT.md` |
| Build or configure Jenkins container image | `docker/jenkins/` | `docker/jenkins/CONTEXT.md` |
| Configure Postgres image or init scripts | `docker/postgres/` | `docker/postgres/CONTEXT.md` |
| Add or run pytest | `tests/` | `tests/CONTEXT.md` |
| Write spec, plan, or task list | `specs/` | `specs/CONTEXT.md` |
| Read reference documentation | `docs/` | `docs/CONTEXT.md` |

## First Move (SOP)

1. **Identify intent** — match the user's request to the routing table above
2. **Teleport** — read only the target room's CONTEXT.md
3. **Execute** — follow that room's process and hard rules exactly
4. **Self-check** — run verification commands before declaring done


