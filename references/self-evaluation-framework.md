# Self-Evaluation Framework

## Why self-evaluation matters

Without a self-evaluation mechanism, Claude's only completion signal is "looks done" —
a subjective assessment that misses regressions, scope creep, and quality gaps.

A self-evaluation rubric gives Claude an objective scoring protocol it can run against its
own output before declaring completion. This makes Claude's "done" mean something measurable.

The goal is not perfection. The goal is that Claude knows when it is NOT done.

---

## How self-evaluation works in an ICM workspace

Self-evaluation happens at three levels:

### Level 1: Room-level verification (end of every task)
Each room CONTEXT.md's "Process" section must end with real verification commands.
Claude must run these and report results before saying done.

### Level 2: Skill-level done criteria (end of every skill invocation)
Every skill file has a "Done when" section. Claude must be able to show evidence that
each criterion is met — not just assert it.

### Level 3: Workspace-level rubric (end of significant tasks)
`.claude/self-eval.md` contains a scored rubric. Claude runs this on tasks that:
- Span multiple rooms
- Touch shared types or interfaces
- Are about to be committed or handed off
- The user asks "is this ready?" or "is this good?"

---

## Self-evaluation rubric template

The rubric lives at `.claude/self-eval.md`. Customize the scoring criteria for the
project, but always include these five dimensions:

### 1. Correctness
What it measures: Did the output do what was asked? Does the verification pass?

```
5 — All verification commands pass. Tests green. Build succeeds. No lint errors.
4 — Passes with pre-existing warnings (not introduced by this task).
3 — Primary test passes. Minor pre-existing failures unrelated to this task.
2 — Build succeeds but new warnings introduced.
1 — Tests fail. Build fails. Lint has new errors.
```

Evidence Claude must show: test output, build output, or lint output — not a claim.

### 2. Scope Discipline
What it measures: Did Claude stay in the right room and change only what was needed?

```
5 — Changed only the files the task required. No opportunistic cleanups.
4 — One small unrelated cleanup, clearly noted in commit message.
3 — Minor scope creep but all changes are in the correct room.
2 — Touched files outside the target room without justification.
1 — Changed large areas outside scope. Multiple rooms affected.
```

Evidence Claude must show: list of modified files and why each was necessary.

### 3. Context Adherence
What it measures: Did Claude follow the room's CONTEXT.md (token budget, process, hard rules)?

```
5 — Followed the room's CONTEXT.md exactly. Process steps followed in order.
4 — Followed the process with one justified deviation, stated explicitly.
3 — Followed the process generally but skipped one non-critical step.
2 — Used the wrong room's context or loaded files outside the token budget.
1 — Did not load any CONTEXT.md. Worked without project-specific context.
```

Evidence Claude must show: which CONTEXT.md was loaded, which process steps were followed.

### 4. Output Quality
What it measures: Does the output meet the room's "What Good Looks Like" criteria?

```
5 — Meets all quality bars defined in the room's CONTEXT.md.
4 — Meets most quality bars. One minor gap, noted.
3 — Meets the primary quality bar. Secondary gaps noted.
2 — Output works but does not meet stated quality bars.
1 — Output does not work or is incomplete.
```

Evidence Claude must show: cross-reference against each bullet in "What Good Looks Like".

### 5. Hard Rule Compliance
What it measures: Were any "Thou shalt NOT" rules violated?

```
5 — No hard rules violated. Every rule was respected.
3 — All hard rules respected, one borderline case where judgment was used.
1 — A hard rule was violated. BLOCKING FAILURE regardless of other scores.
```

Evidence Claude must show: statement of which hard rules applied and that each was followed.

---

## Self-evaluation scoring

| Total (out of 25) | Verdict | Action |
|-------------------|---------|--------|
| 23-25 | DONE | Ready to commit or hand off |
| 18-22 | DONE WITH NOTES | Document gaps in commit message |
| 13-17 | NOT DONE | Fix the lowest-scoring dimension first |
| Below 13 | RESTART | Call `/clear`. Start the task fresh. |

A score of 1 on Hard Rule Compliance = automatic NOT DONE regardless of total.

---

## Self-report format Claude must use

Before any "done" statement on a significant task:

```
Self-evaluation for: [task description]

Correctness:       [N]/5 — [one sentence of evidence]
Scope Discipline:  [N]/5 — [one sentence of evidence]
Context Adherence: [N]/5 — [one sentence of evidence]
Output Quality:    [N]/5 — [one sentence of evidence]
Hard Rules:        [N]/5 — [one sentence of evidence]

Total: [N]/25
Verdict: DONE / DONE WITH NOTES / NOT DONE / RESTART

[If NOT DONE: what specifically needs to be fixed]
[If DONE WITH NOTES: what the notes are]
```

Claude must not say "done" without this report for tasks of non-trivial complexity.

---

## Outcome-based verification (advanced)

For high-stakes tasks, use an outcome rubric — a statement of what success looks like
that Claude (or a second agent) can evaluate against.

```markdown
## Outcome: [Feature name]

Success looks like:
1. [Observable criterion — something that can be verified with a command or visual check]
2. [Observable criterion]
3. [Observable criterion]

Failure looks like:
- [Specific failure mode]
- [Specific failure mode]

Verification command:
[Exact command that produces pass/fail evidence]
```

This is more rigorous than a quality bar because it's binary — either the outcome is met or
it isn't — and verification is objective, not subjective.

---

## The "two failures = /clear" rule

If Claude makes two consecutive failed attempts to fix the same problem:
1. Context accumulation is working against it (failed approaches fill the window)
2. Call `/clear` to reset the context
3. Start fresh with a clean statement of the problem
4. Do not carry over assumptions from the failed attempts

This is not defeat. It is context hygiene. A fresh context solves problems faster than a
polluted one with accumulated failed reasoning.

---

## Integrating self-evaluation into the workspace

### In AGENTS.md
Add a brief self-eval reference:
```markdown
## Self-Evaluation
Before marking any task done, Claude runs `.claude/self-eval.md`.
Score 18+ = done. Score below 13 = restart with /clear.
```

### In room CONTEXT.md Process sections
End every process with:
```markdown
4. **Refine** — Run [test command]. If any fail, fix and re-run. Report results.
5. **Self-check** — Run `.claude/self-eval.md` if this task is being handed off or committed.
```

### In skill "Done when" sections
Always include a verification criterion:
```markdown
## Done when
- [Specific test command] passes
- No regressions in the full test suite
- Self-eval score ≥ 18 if this will be committed
```

---

## Anti-patterns in self-evaluation

| Anti-pattern | Fix |
|--------------|-----|
| "Looks good" without evidence | Require runnable verification commands |
| Self-eval rubric never used in practice | Make it mandatory for hand-offs via Stop hook |
| Scoring all 5s habitually | Rubric is calibrated wrong — make bars measurable |
| Rubric with subjective criteria | Replace "clean code" with "passes lint with 0 errors" |
| Separate grader agent never consulted | Use a subagent for verification on high-stakes tasks |
