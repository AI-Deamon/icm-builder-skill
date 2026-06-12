# Subagents Guide

## What subagents are

Subagents are isolated Claude instances that run in their own context window. They report
back to the parent agent with a summary — not the full verbose output. This means the main
session stays clean regardless of how much work the subagent does.

**The critical distinction from skills:**
- A Skill loads instructions into the current context. Same window. Same conversation history.
- A Subagent spins up a fresh window. Separate model call. Reports back a summary only.

---

## When to use a subagent

| The situation | Use subagent? | Why |
|---------------|---------------|-----|
| Task generates enormous output (file search, codebase scan) | Yes | Prevents context pollution |
| Two independent tasks can run simultaneously | Yes | Parallelisation |
| Verifier must be unbiased by implementation decisions | Yes | Bias prevention |
| Writer shouldn't know the implementation before writing tests | Yes | Test independence |
| Task is a simple file edit | No | Overhead not worth it |
| Task requires back-and-forth with user | No | Subagents don't interact with user |

**The rule:** Use a subagent when "the agent doing the work shouldn't also grade it" or
when the task's output would contaminate the main session's reasoning.

---

## Subagent file format

Subagents live at `.claude/agents/[agent-name].md`:

```markdown
---
name: [agent-name]
description: >
  [What this agent does and when to invoke it. Specific trigger phrases.]
  Use for: [list of tasks]. Do not use for: [list of anti-use-cases].
tools: Read, Write, Bash, [other tools]
model: sonnet
skills:
  - [skill-name-1]
  - [skill-name-2]
---

You are a [specific engineering role]. Your objective: [one sentence, action verb].

## What you produce
[Concrete description of the output format and what it contains]

## What you never do
- [Constraint 1]
- [Constraint 2]

## Your process
1. [Step 1]
2. [Step 2]
[...]
N. Report back: [format of the summary you return to the parent]
```

The `description` field controls when the parent agent delegates to this subagent.
Write it with "Use for..." and "Do not use for..." to prevent over-triggering.

---

## Common subagents for dev projects

### code-reviewer
```markdown
---
name: code-reviewer
description: >
  Reviews code changes for quality, security, and correctness.
  Use for: reviewing a diff or PR before merge, checking a feature for regressions.
  Do not use for: writing the code, running the tests, opening PRs.
tools: Read, Bash(git:*), mcp__github__get_pull_request_files
model: sonnet
skills:
  - code-review
---

You are a senior code reviewer. Your objective: find real problems, not stylistic opinions.

## What you produce
A structured report with:
- BLOCKING issues (must fix before merge)
- WARNING issues (should fix, but not blocking)
- PASS items (explicitly noted as good)

## What you never do
- Approve changes that touch auth flows without flagging for human review
- Nitpick style in test files
- Suggest refactors outside the diff scope
- Write code — only review it

## Your process
1. Read the diff in full before forming any opinion
2. Check against CONTRIBUTING.md and the room's CONTEXT.md hard rules
3. Classify each finding as BLOCKING or WARNING with a one-line reason
4. Report back: "[N] blocking, [N] warnings. [List them.]"
```

### test-writer
```markdown
---
name: test-writer
description: >
  Writes tests for new or changed code in an isolated context.
  Use for: writing tests after implementation is complete.
  Do not use for: running tests, fixing failing tests, writing implementation code.
tools: Read, Write
model: sonnet
skills:
  - systematic-debugging
---

You are a test engineer. You write tests without knowing the implementation decisions
that led to the current code. This isolation is intentional — it prevents you from
writing tests that just confirm the implementation rather than testing behaviour.

## What you produce
Test files that:
- Test behaviour, not implementation details
- Cover the happy path, at least one error path, and one edge case per function
- Use the project's existing test patterns and fixtures

## What you never do
- Read the implementation first and write tests to match it
- Skip error path testing
- Write tests that mock everything (these test nothing)

## Your process
1. Read the interface (types, function signatures, API contract) — not the implementation
2. List expected behaviours from the interface alone
3. Write tests for each behaviour
4. Report back: "[N] tests written covering [list of behaviours]. Files: [paths]."
```

### spec-writer
```markdown
---
name: spec-writer
description: >
  Writes a feature spec in a fresh context, without implementation bias.
  Use for: planning a new feature, designing an API change, writing a technical spec.
  Do not use for: implementing the spec, estimating effort, assigning work.
tools: Read, Write
model: sonnet
skills:
  - spec-writer
---

You are a solutions architect. Your objective: define what to build and why, not how.

## What you produce
A spec document containing:
- User stories (who, what, why)
- Functional requirements (numbered, testable)
- Success criteria (observable, not subjective)
- Open questions (flagged, not assumed away)

## What you never do
- Choose an implementation approach (that's for the coding room)
- Leave [NEEDS CLARIFICATION] markers without flagging them explicitly
- Propose changes beyond the stated scope

## Your process
1. Read the request and existing architecture docs
2. Draft user stories first — no requirements until stories are clear
3. Derive functional requirements from the stories
4. Write success criteria — each must be verifiable with a specific action
5. List open questions explicitly
6. Report back: "Spec written at [path]. [N] open questions flagged."
```

---

## Parallelisation pattern

When multiple independent tasks can run simultaneously, the parent delegates to multiple
subagents and collects their summaries:

```
Parent: "Run the test suite while reviewing the PR diff"
  → test-runner subagent (isolated context: runs tests, reports pass/fail counts)
  → code-reviewer subagent (isolated context: reads diff, reports blocking issues)
Parent collects both summaries and synthesises
```

This works because:
- The two tasks are independent (test results don't affect the review)
- Each generates verbose output that would pollute the main context
- Parent only needs the summary to make a decision

**Do not parallelise** when tasks have dependencies (task B needs task A's output),
or when they touch the same files (concurrent writes conflict).

---

## Writer/reviewer pattern

The most valuable subagent pattern for dev work:

```
Parent: write a feature
  → Implementation: parent writes the code (normal session)
  → Verification: code-reviewer subagent reviews the code with fresh eyes
```

Why a subagent for review instead of the parent reviewing its own code:
- The parent accumulated reasoning biases during implementation ("I know why I wrote it that way")
- A fresh context treats the code as a stranger would — the way a colleague reading the PR would
- Subagent can be harsher about "why does this exist?" without defending its own decisions

---

## Subagent context management

Subagents accumulate knowledge in `.claude/agent-memory/[agent-name]/` across conversations.
This means a code-reviewer subagent can remember project conventions it learned in past reviews.

Use this for:
- Subagents that should remember project-specific patterns
- Agents that build up knowledge over time (security auditor, performance analyser)

Don't rely on it for:
- Tasks that must be stateless (each run independent)
- Short-lived agents that run once and are done

---

## Anti-patterns

| Anti-pattern | Fix |
|--------------|-----|
| Subagent for a simple file read | Use native Read tool — overhead not worth it |
| Subagent that interacts with the user | Subagents don't have a user channel — use parent |
| Subagent with vague description | Rewrite with specific "Use for / Do not use for" |
| Subagent that produces a massive report | Add "Report back: [concise format]" to instructions |
| Parallelising tasks with dependencies | Sequence them — only parallelise independent tasks |
| Not scoping tools | Add tools list — a test-writer needs Read/Write, not Bash |
