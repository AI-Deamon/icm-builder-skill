# api/CONTEXT.md (web-app version — shows the same pattern with different content)
# ─────────────────────────────────────────────────

# CONTEXT.md — api/

**Last updated**: 2026-06-12
**Location**: `api/` at repo root
**Layer**: 2 (Distributed)

## 1. Room Definition

**Persona**: Node.js / Express / Stripe Integration Engineer
**Objective**: Ship API endpoints, business logic, and billing integrations. Touch only this
folder unless shared types need updating.

## 2. Token Budget

| Task | Load | Skip |
|------|------|------|
| Add a REST endpoint | `api/src/routes/`, `api/src/middleware/`, `shared/types.ts` | `src/`, `api/migrations/` |
| Add business logic | `api/src/services/`, `api/src/models/` | `src/`, `api/migrations/` |
| Fix Stripe integration | `api/src/webhooks/`, `api/src/services/billing.ts`, `shared/types.ts` | `src/`, `api/migrations/` |
| Add database model | `api/src/models/`, `shared/types.ts` | `src/`, `api/src/webhooks/` |
| Fix middleware | `api/src/middleware/`, `api/src/routes/` | `src/`, `api/src/webhooks/` |
| Add API test | `api/tests/`, `api/src/` module under test | `src/`, `api/migrations/` |

## 3. Local Map

```
api/
├── src/
│   ├── routes/         # Express routers — thin, no business logic
│   ├── services/       # Business logic (billing.ts, users.ts, teams.ts)
│   ├── models/         # Knex query builders — no raw SQL outside models/
│   ├── middleware/     # auth.ts, rateLimit.ts, errorHandler.ts
│   ├── webhooks/       # Stripe event handlers (separate from routes/)
│   └── app.ts          # Express entrypoint
├── tests/              # Jest + supertest
├── migrations/         # Knex migration files (see migrations/CONTEXT.md)
├── package.json
└── knexfile.ts
```

## 4. The Process

1. **Source** — read the relevant `src/` module and `shared/types.ts` if types are involved
2. **Plan** — draft the function signature, list callers, identify if a migration is needed
3. **Execute** — write the service/route; update `shared/types.ts` if API surface changes;
   add a Jest test in `api/tests/`
4. **Refine** — `cd api && npm run test` (full suite must pass); `npm run lint`

## 5. What Good Looks Like

- All business logic in `services/`. Route handlers contain only: parse request, call service,
  send response. No business logic in routes.
- Every new endpoint has: one success test, one auth-failure test, one validation-error test.
- Stripe webhook handlers are idempotent — processing the same event twice produces the same state.
- Zero `any` types in TypeScript. All DB queries go through `models/`.

## 6. Constraints

- **Business logic location**: Do not put business logic in route handlers. It belongs in services/.
- **Stripe secret**: Do not log `STRIPE_WEBHOOK_SECRET`. If a webhook silently fails, check the
  secret match before assuming a code bug.
- **Migration safety**: Do not edit migrations that have already run. Create a new migration.
- **Shared types**: If changing an API response shape, update `shared/types.ts` before the API
  code — the frontend depends on it.

## 7. Skills Available in This Room

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `/systematic-debugging` | Test fails or unexpected API behaviour | Hypothesis-first debugging |
| `/verification-before-completion` | Before any PR | Lint + test gate |

## 8. MCP Servers Available in This Room

| Server | Access | Use for |
|--------|--------|---------|
| `postgres` | read-only | Verify data state, debug query results |
| `github` | read-write | Open PRs, fetch diffs for review |
| `linear` | read-only | Read ticket context before implementing |

## 9. Hard Rules

- **Thou shalt NOT put business logic in route handlers.** Services exist for this. Routes that
  contain business logic cannot be unit tested without an HTTP layer.
- **Thou shalt NOT edit a migration that has already run.** Running a modified migration against
  an existing schema causes constraint violations or silent data corruption.
- **Thou shalt NOT use `npm run db:reset` against staging.** It drops the entire database.
  The only safe reset target is a local development environment.


