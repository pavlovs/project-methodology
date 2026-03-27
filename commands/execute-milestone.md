# /execute-milestone

You are entering **milestone execution mode**. Follow this protocol exactly.

## Step 1 — Read the plan

Read `ai/PLAN-M{n}.md` completely. Also read:
- `ai/LEARNINGS.md` — constraints you must not violate
- `ai/ARCHITECTURE.md` — architectural invariants
- `CLAUDE.md` — project non-negotiables

If `ai/PLAN-M{n}.md` does not exist, stop and ask the user to run `/plan-milestone` first.

## Step 2 — Implement

Follow the numbered steps in the Plan section exactly. For each step:
- Complete it fully before moving to the next
- If you discover the plan is wrong or incomplete: implement what you can, note the deviation, and flag it for the user at the end — do not silently improvise
- If you discover a structural problem that must be fixed first: stop, report it, propose a path forward

**Minimum user interaction during implementation.** Validate autonomously. Only surface blockers that truly require human input (OAuth, hardware, external accounts).

## Step 3 — Validate

Run every command in the **AI validation plan** section of the milestone plan. Record exact outputs.

Required at minimum for any milestone:
- `pytest tests/` passes (no regressions)
- The primary CLI command runs live (`--limit 5` or equivalent, not just mocked tests)
- `python pipeline.py status` (or equivalent) shows expected stage counts
- Any output files open and are valid (not corrupt, not empty)

If validation fails: diagnose the root cause, fix, re-run. Do not mark done with a failing test.

## Step 4 — Fill in validation results

Update the **AI validation results** section of `ai/PLAN-M{n}.md` with:
- Exact commands run
- Exact outputs (counts, file names, any errors)
- Any deviations from the plan and why

## Step 5 — Better engineering phase

After the milestone works, do this in parallel:

**(a) Update `ai/LEARNINGS.md`**
- Add any new durable lessons (things that would cost a future developer time if unknown)
- Remove anything that's now better documented in code or architecture
- Follow the scope ladder: repo-wide wisdom → LEARNINGS.md; app-specific policy → ARCHITECTURE.md; symbol-local → code comments

**(b) Update `ai/ARCHITECTURE.md`**
- Reflect any architectural decisions made or changed during this milestone
- Update invariants if they changed
- Remove anything stale

**(c) Self-review checklist** — all must be true:
- [ ] Type hints on all new function signatures
- [ ] No hardcoded values — all constants flow from config/settings
- [ ] `--dry-run` works on all commands that hit external APIs
- [ ] `pytest tests/` passes
- [ ] Output files valid (no corrupt Excel, empty HTML, broken JSON)
- [ ] `PLAN-M{n}.md` AI validation results section filled
- [ ] `ARCHITECTURE.md` / `LEARNINGS.md` updated if any design decision changed
- [ ] One commit covers implementation + tests + doc updates together

## Step 6 — Commit

Stage and commit: implementation files + tests + plan file (with results) + updated docs.
One commit per milestone. Do not batch with other milestones.

## Step 7 — Present to user

Tell the user:
1. What was built (1–2 sentences)
2. The validation results (counts, test output)
3. Any deviations from the plan
4. What to try (exact commands/steps for manual verification)
5. What the next milestone is

Mark the milestone ✅ in `ai/PLAN.md` only after all checklist items above are confirmed true.
