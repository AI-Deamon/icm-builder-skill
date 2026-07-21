# UPDATE Mode — Drift Detection and Patching

Enter this mode when Phase 0 finds `AGENTS.md` with the `<!-- icm:managed -->` marker,
or when the user asks to "update", "refresh", "fix", or "re-sync" their ICM workspace.

The goal: keep the workspace truthful as the project evolves, WITHOUT discarding the
user's accumulated customizations. UPDATE mode patches; it never blindly regenerates
content files from scratch.

## Step 1: Load current state

Read, in this order:

1. `.icm/manifest.md` — the list of managed files and the scan snapshot from last run.
   If it is missing, reconstruct what you can from AGENTS.md and note the gap.
2. `AGENTS.md` — current source of truth.
3. The routing table — to know which rooms are supposed to exist.

Do NOT read every room CONTEXT.md yet — only the ones drift analysis flags.

## Step 2: Re-scan

Run `scripts/scan.sh` (or the manual scan from ICM-BUILDER.md Phase 1) on the project root.

## Step 3: Drift report

Compare the fresh scan against the manifest snapshot and the current files. Present ONE
report before changing anything:

```
Drift report ([date] vs manifest of [manifest date]):

NEW — needs a decision:
- New top-level folder `[x]/` with [N] files — no room exists. Create a room?
- New command in package.json: `[name]` — not in AGENTS.md Commands.
- New external system config found: [e.g., sentry config] — no MCP entry.

STALE — will fix automatically on confirm:
- AGENTS.md lists command `[old]` but package.json now has `[new]`.
- Room `[y]/CONTEXT.md` Local Map references `[path]` which no longer exists.
- Routing table row "[intent]" points to deleted folder `[z]/`.
- Per-tool copy `[CLAUDE.md]` differs from AGENTS.md (someone edited the copy).

REMOVED:
- Folder `[z]/` deleted but its CONTEXT.md row remains in routing table.

UNCHANGED: [count] managed files verified current.
```

## Step 4: Patch (after user confirms)

- **Stale commands/paths**: edit in place. Touch only the wrong lines.
- **New folders → new rooms**: run the abbreviated flow — ask the room questions from
  Phase 2 for that folder only, then build its CONTEXT.md per Phase 6.
- **Removed rooms**: delete the routing rows and the orphaned CONTEXT.md (ask first).
- **Edited per-tool copies**: if the copy has changes the user wants to keep, merge them
  INTO AGENTS.md first. Then regenerate every per-tool copy from AGENTS.md per
  `references/output-adapters.md`. Copies are always regenerated last.
- **User's manual edits inside managed files**: preserve them. If a manual edit conflicts
  with the scan (e.g., they documented a command that no longer exists), flag it in the
  drift report rather than silently overwriting.

## Step 5: Refresh the manifest

Rewrite `.icm/manifest.md` with today's date, the new scan snapshot, and the updated
managed-file list. Update the `generated=` date in the `<!-- icm:managed -->` marker.

## Step 6: Verify

Run the same verification as Phase 11: ask the routing question and the self-eval
question. Additionally confirm:

- [ ] Every folder with active work has a room in the routing table
- [ ] Every command in AGENTS.md still runs
- [ ] All per-tool copies are byte-identical to AGENTS.md (after header/frontmatter)
- [ ] Manifest date updated

## When to recommend UPDATE mode proactively

The generated AGENTS.md tooling rules tell agents to re-run icm-builder when they notice
a new top-level folder, changed command, or missing room. When a user complains that
"the agent keeps getting X wrong" in an ICM workspace, drift is the first suspect —
offer UPDATE mode before hand-editing individual files.
