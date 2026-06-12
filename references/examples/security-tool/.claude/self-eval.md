# ─────────────────────────────────────────────────
# .claude/self-eval.md
# ─────────────────────────────────────────────────

# Self-Evaluation Rubric — Archer Security Pipeline

Run this before marking any non-trivial task as done.
Score each dimension. Any dimension scored 1 = task is NOT done.

## Dimensions

### 1. Correctness (1-5)
5 — `pytest tests/ -v` passes. `npx vitest run` passes. `npm run build` succeeds. No new lint errors.
4 — All pass with pre-existing warnings not introduced by this task.
3 — Primary test passes. Minor unrelated pre-existing failures.
2 — Build succeeds but new lint warnings were introduced.
1 — Tests fail. Build fails. New lint errors exist.

Evidence required: paste the last line of test output (e.g. "15 passed in 0.8s").

### 2. Scope Discipline (1-5)
5 — Only changed files the task required. No opportunistic cleanups.
4 — One unrelated cleanup, noted in commit message.
3 — Minor scope creep, all changes in the correct room.
2 — Touched files outside the target room without clear justification.
1 — Changed multiple rooms or large areas outside scope.

Evidence required: list of modified files and one-line reason each was necessary.

### 3. Context Adherence (1-5)
5 — Loaded the correct room's CONTEXT.md. Followed process steps in order.
4 — Correct room loaded, one justified deviation stated explicitly.
3 — Correct room loaded, skipped one non-critical process step.
2 — Wrong room loaded or token budget ignored (loaded files marked Skip).
1 — No CONTEXT.md loaded. Worked without project context.

Evidence required: name the CONTEXT.md that was loaded and which process steps were followed.

### 4. Output Quality (1-5)
5 — Meets all "What Good Looks Like" criteria in the room's CONTEXT.md.
4 — Meets most criteria. One minor gap noted.
3 — Meets the primary criterion. Secondary gaps noted.
2 — Output functions but does not meet stated quality bars.
1 — Output does not function or is incomplete.

Evidence required: cross-reference each bullet in "What Good Looks Like" with a pass/fail.

### 5. Hard Rule Compliance (1-5)
5 — No hard rules violated.
3 — All rules respected, one borderline case where judgment was applied (stated explicitly).
1 — A hard rule was violated. BLOCKING — task is NOT done regardless of other scores.

Evidence required: list which hard rules applied to this task and confirm each was followed.

## Scoring

Total: [sum] / 25

| Score | Verdict | Action |
|-------|---------|--------|
| 23-25 | DONE | Ready to commit |
| 18-22 | DONE WITH NOTES | Document gaps in commit message |
| 13-17 | NOT DONE | Fix lowest-scoring dimension first |
| Below 13 | RESTART | Call /clear, start the task fresh |

## Self-report format

```
Self-evaluation for: [task]
─────────────────────────────
Correctness:       [N]/5 — [evidence]
Scope Discipline:  [N]/5 — [modified files: X, Y, Z — reasons]
Context Adherence: [N]/5 — [loaded: backend/CONTEXT.md, followed steps 1-4]
Output Quality:    [N]/5 — [criteria met/not met]
Hard Rules:        [N]/5 — [rules checked: dual-scans, celery-rebuild, etc.]

Total: [N]/25
Verdict: DONE / DONE WITH NOTES / NOT DONE / RESTART
```
