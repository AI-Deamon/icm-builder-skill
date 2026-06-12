# .claude/skills/verification-before-completion/SKILL.md
# ─────────────────────────────────────────────────

---
name: verification-before-completion
description: >
  Use before marking any feature, fix, or task as complete. Use before any PR.
  Use when asked "is this ready?" or "is this done?". Runs the full verification
  sequence and blocks completion until all checks pass. Do not skip any step.
allowed-tools: Bash
---

# Verification Before Completion

## When to invoke
- Before saying "done", "complete", or "finished"
- Before opening a PR or pushing to a shared branch
- When the user asks "is this ready?" or "can we ship this?"
- After any change to shared types (`src/types.ts`, `app/schemas/`)

## Protocol

Run in order. Stop and report failure at the first step that fails.
Do not skip steps. Do not declare done if any step produces errors.

1. **Backend lint + typecheck**
   ```bash
   cd backend && ruff check . && mypy app/
   ```
   Expected: zero errors. Warnings only if pre-existing.

2. **Backend tests**
   ```bash
   pytest tests/ -v
   ```
   Expected: all pass. No new skips. No new warnings.

3. **Frontend lint + typecheck**
   ```bash
   npm run lint && npx tsc -b
   ```
   Expected: zero errors. `npm run build` if typecheck is insufficient.

4. **Frontend tests**
   ```bash
   npx vitest run
   ```
   Expected: all pass. No new skips.

5. **Docker build check** (if Dockerfile was touched)
   ```bash
   docker compose -f docker/docker-compose.yml \
     -f docker/docker-compose.staging.yml \
     build --no-cache backend celery_worker
   ```
   Expected: build succeeds with no errors.

6. **Smoke check** (if API or UI was changed)
   - `python run.py staging`
   - Wait 2-3 minutes for services to be healthy
   - Navigate to http://localhost:5173 and verify the affected feature works

## Report format

```
Verification result for: [task description]
─────────────────────────────────────────
Backend lint:     PASS / FAIL ([N] errors)
Backend tests:    PASS / FAIL ([N] failures)
Frontend lint:    PASS / FAIL ([N] errors)
Frontend tests:   PASS / FAIL ([N] failures)
Docker build:     PASS / FAIL / SKIPPED
Smoke check:      PASS / FAIL / SKIPPED

Verdict: READY / NOT READY
Blockers: [list anything that failed — specific error, not just "tests failed"]
```

## Done when
All steps show PASS or SKIPPED (with justification). Verdict is READY.
If anything fails, fix it and re-run the full sequence from step 1.

