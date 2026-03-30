# {Project Name} — Master Plan

## Vision

{1 paragraph: what this project is, what problem it solves, long-term trajectory}

## Project Goal

{3–5 bullet points: what the pipeline/system does, ordered by importance}

## Milestone Overview

| #   | Milestone         | Description                                      | Status |
| --- | ----------------- | ------------------------------------------------ | ------ |
| M1  | Infrastructure    | Env setup, CLI skeleton, data model, tests       | ⬜      |
| M2  | {next milestone}  | {description}                                    | ⬜      |

Status: ⬜ = not started, 🔄 = in progress, ✅ = complete

---

## Current State

{Updated at each session end — 5–8 lines max}
- Last updated: {date}
- What's done: ...
- What's in DB/state: ...
- Next up: M{n} — {title}
- Full roadmap: `ai/ROADMAP.md`

---

## Definition of Done — Hard Gate

A milestone is NOT complete and must NOT be marked ✅ until ALL of the following are true:

1. `ai/PLAN-M{n}.md` exists with `## AI VALIDATION RESULTS` filled in (not blank)
2. `pytest tests/` passes — no regressions
3. The primary command ran live (`--limit 5` minimum) against real data — not just mocked tests
4. `python {entrypoint}.py status` (or equivalent) shows expected state counts
5. `PLAN-M{n}.md` PM Review section shows PASS (original or after amendments)
6. If DB schema, output format, API behavior, or prompt logic changed: `ARCHITECTURE.md` updated in the same commit
7. One commit covers implementation + tests + doc updates. Batch commits across milestones = planning was skipped.

---

## HOW TO PLAN A MILESTONE

Run `/plan-milestone` to invoke the full planning protocol. Summary:

1. Read PLAN.md + all prior PLAN-M{k}.md + ARCHITECTURE.md + LEARNINGS.md
2. Research discoverable facts from the codebase before asking questions
3. Ask clarifying questions only for preferences/tradeoffs that cannot be discovered
4. Write `ai/PLAN-M{n}.md` — decision-complete, self-contained, executor needs zero further decisions
5. Check for engineering blockers (small = Phase 0 in plan; large = propose new blocking milestone)
6. Validate plan against LEARNINGS.md — fix any violations
7. Present for user signoff. Do not begin execution without approval.

---

## HOW TO EXECUTE A MILESTONE

Run `/execute-milestone` to invoke the full execution protocol. Summary:

1. Read PLAN-M{n}.md, LEARNINGS.md, ARCHITECTURE.md, CLAUDE.md
2. Implement following plan steps exactly; flag deviations
3. Run all validation commands; record exact outputs in PLAN-M{n}.md
4. Run `/review-milestone` (PM Review — Opus): REQUIRED fixes auto-amended + documented; CLARIFY items batched to project owner
5. Better engineering phase: update LEARNINGS.md + ARCHITECTURE.md
6. Self-review checklist (type hints, dry-run, tests, output files, docs, PM review PASS)
7. One commit: implementation + tests + plan file (with PM review) + doc updates
8. Mark ✅ in this file only after all checklist items confirmed true

---

## Cost Budget (if applicable)

{e.g. Claude API: haiku ~€0.001/record. Target: <€X/month for full run of Y records.}
