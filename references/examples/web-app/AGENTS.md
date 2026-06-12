# Example: SaaS Web Application
# Project type: Standard SaaS product
# Stack: Next.js 14 + Node/Express API + PostgreSQL + Redis + Stripe
#
# Read this AFTER the security-tool example to understand how the same
# ICM pattern adapts to a completely different project type.
# Only showing the differences — the structural pattern is identical.
# ─────────────────────────────────────────────────

# AGENTS.md (web-app version)

Pulse — B2B SaaS analytics platform: Next.js 14 frontend + Express API + PostgreSQL + Redis + Stripe billing.

## Commands

### Frontend
```bash
npm run dev          # Next.js dev server on :3000
npm run build        # Production build + typecheck
npm run test         # Jest + React Testing Library
npm run lint         # ESLint + Prettier check
```

### API
```bash
cd api && npm run dev          # Nodemon on :4000
cd api && npm run test         # Jest integration tests
cd api && npm run migrate      # Run pending Knex migrations
cd api && npm run migrate:down # Rollback last migration
```

### Database
```bash
psql $DATABASE_URL             # Connect to local DB
npm run db:seed                # Seed development data
npm run db:reset               # DROP + recreate + seed (dev only, destroys data)
```

## Architecture

| Layer | Path | Notes |
|-------|------|-------|
| Frontend | `src/` | Next.js App Router, server + client components |
| API | `api/src/` | Express, Knex ORM, Stripe webhook handler |
| API tests | `api/tests/` | Jest, supertest — mocks Stripe + email |
| Frontend tests | `src/__tests__/` | Jest + RTL — mocks API calls |
| DB migrations | `api/migrations/` | Knex migration files — never edit directly |
| Shared types | `shared/` | TypeScript types used by both frontend and API |
| Stripe webhooks | `api/src/webhooks/` | Event handlers — separate from API routes |

## Routing Table

| User intent | Room | Read |
|-------------|------|------|
| Add API endpoint, fix business logic, Stripe integration | `api/` | `api/CONTEXT.md` |
| Add page, component, hook, or server action | `src/` | `src/CONTEXT.md` |
| Write or run database migration | `api/migrations/` | `api/migrations/CONTEXT.md` |
| Add or fix tests | `api/tests/` or `src/__tests__/` | appropriate CONTEXT.md |
| Write feature spec or ADR | `docs/decisions/` | `docs/CONTEXT.md` |

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Migration file | `[timestamp]_[description].js` | `20260612_add_team_slug.js` |
| API test | `[module].test.ts` | `billing.test.ts` |
| Frontend test | `[Component].test.tsx` | `PricingTable.test.tsx` |
| ADR | `docs/decisions/NNN-title.md` | `docs/decisions/007-use-redis-for-sessions.md` |

## Gotchas

- **`npm run db:reset` destroys data**: Drops the entire database. Never run against staging.
  Use `npm run migrate` to apply only pending migrations.
- **Stripe webhook secret**: `STRIPE_WEBHOOK_SECRET` must match the Stripe Dashboard endpoint
  secret exactly. Using the wrong secret silently drops all webhook events (200 OK but ignored).
- **Server vs. client components**: Next.js App Router — components are server by default.
  Adding `useState` or `useEffect` without `"use client"` directive throws a cryptic hydration error.
- **Knex migration order**: Migrations run alphabetically by timestamp. Never edit a migration
  that has already run in any environment — create a new one instead.
- **Redis session TTL**: Sessions expire after 24h. If a user reports "logged out randomly",
  check Redis TTL config before assuming an auth bug.

## Style
- **API**: async/await throughout. No callbacks. All routes in `api/src/routes/`, all business
  logic in `api/src/services/`. Never put business logic in route handlers.
- **Frontend**: Server Components for data fetching. Client Components for interactivity only.
- **Types**: Shared types live in `shared/types.ts` — never duplicate between frontend and API.
- **Verify before done**: `npm run lint && npm run build && npm run test && cd api && npm run test`


