# ─────────────────────────────────────────────────
# .claude/skills/pipeline-stage-spec/SKILL.md
# ─────────────────────────────────────────────────

---
name: pipeline-stage-spec
description: >
  Use when adding a new Jenkins pipeline stage, changing stage ordering, or defining
  a callback contract. Produces a complete stage specification with all four required
  components before any Jenkinsfile is edited. Do not invoke for routine Jenkinsfile
  formatting or version pin changes.
allowed-tools: Read Bash(cat:*) Bash(grep:*)
---

# Pipeline Stage Spec

## When to invoke
- Adding a new scan tool or stage to the Jenkinsfile
- Changing the order of existing stages
- Modifying a callback payload structure
- Asked to design a new CI/CD step

## The four required components (a stage is incomplete without all four)

Every stage must have:
1. **Name** — the display name in Jenkins UI
2. **Tool list** — exact tools used, with version pins
3. **Execution order** — where in the pipeline this stage runs and why
4. **Success criteria** — observable, testable — not "stage completes"

## Protocol

1. **Read the current Jenkinsfile** — understand the existing stage order and callback structure

2. **Draft the stage spec** in this format before touching the Jenkinsfile:
   ```
   Stage: [name]
   Tools: [tool1 v1.2.3, tool2 v4.5.6]
   Position: after [stage X], before [stage Y]
   Reason for position: [why this order matters]
   Inputs: [what the stage reads from the workspace or previous stages]
   Success criteria: [observable check — e.g. "exit 0 AND findings.count > 0"]
   Failure handling: [what happens on non-zero exit]
   Callback payload: [exact JSON structure sent to backend]
   ```

3. **Verify callback contract** — the backend expects `stages` key (not `STAGE_RESULTS`).
   Error keys accept both cases (`ERROR_MESSAGE`, `error_message`).

4. **Check for conflicts** — does this stage conflict with any pinned tool versions
   (SonarQube 26.5, Jenkins 2.528.3, NodeJS plugin)?

5. **Write the Jenkinsfile changes** only after the spec is confirmed

6. **Update `Agent/notes_track`** with the stage change and date

## Done when
- Stage spec has all four required components
- Callback payload matches the backend's expected schema
- Jenkinsfile passes syntax validation
- `Agent/notes_track` is updated

