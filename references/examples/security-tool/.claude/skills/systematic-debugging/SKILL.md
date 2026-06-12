# Layer 3 Skills for the security-tool example
# ─────────────────────────────────────────────────

# .claude/skills/systematic-debugging/SKILL.md

---
name: systematic-debugging
description: >
  Use when a test fails, a scan stage produces unexpected output, or behaviour differs
  between environments. Forces hypothesis-first debugging — state the suspected root cause
  before touching any code. Do not invoke for routine feature development.
allowed-tools: Read Bash(cat:*) Bash(grep:*) Bash(find:*) Bash(pytest:*) Bash(docker:*)
---

# Systematic Debugging

## When to invoke
- A pytest case fails and the cause is not immediately clear
- A Jenkins stage passes but produces zero findings (SonarQube false PASS pattern)
- Behaviour differs between dev and staging environments
- You are about to make your second consecutive guess-and-check edit
- The user says "I can't figure out why this is broken"

## Do NOT invoke for
- Routine feature development where tests pass
- Style or formatting issues

## Protocol

1. **Stop editing.** Make no code changes yet.

2. **State your hypothesis.** Write exactly: "I believe the failure is caused by [X]
   because [Y evidence from the error output]." If you cannot form a hypothesis,
   that is your starting data point — read more first.

3. **Read the full failure signal.**
   - For pytest: read the complete traceback, not just the assertion line
   - For Jenkins: `docker logs archer-jenkins --tail=200` or fetch via Jenkins MCP
   - For SonarQube: check `findings.count` in callback payload AND `docker ps` for container status
   - For Celery: check `docker logs archer-celery_worker --tail=100`

4. **Check the narrowest scope first.** Before reading entire modules:
   - Pytest failure → read the specific function the test calls
   - Import error → check `app/core/celery_app.py` for the broken import path
   - Scan stuck RUNNING → check `ix_scans_project_state` constraint via postgres MCP

5. **Verify, don't assume.** Run the failing test in isolation:
   `pytest tests/[file].py::[test_name] -v`
   Compare actual output to your hypothesis. Update the hypothesis if wrong.

6. **Environment divergence check.** If it works in dev but not staging:
   - Check `CALLBACK_TOKEN` matches exactly between Jenkinsfile and backend env
   - Check SonarQube container is healthy: `docker ps | grep sonarqube`
   - Check celery_worker was rebuilt alongside backend

7. **If two consecutive hypotheses fail:** Call `/clear`. State the situation cleanly
   in a fresh session. Do not carry assumptions from failed attempts forward.

8. **Fix the root cause, not the symptom.** Minimum change that addresses the actual cause.
   Do not clean up unrelated code in the same commit.

9. **Verify the fix:**
   - Backend: `pytest tests/ -v` (full suite must pass)
   - Frontend: `npx vitest run` (full suite must pass)
   - Full stack: `python run.py staging` and trigger a test scan

## Done when
- The originally failing test passes
- Full test suite passes (no new failures)
- You can state in one sentence what the root cause was and why the fix addresses it


