# /execute-milestone

You are entering **milestone execution mode**. Follow this protocol exactly.

## Context (pre-computed at invocation)

```
Branch:         $(git branch --show-current 2>/dev/null || echo "unknown")
Uncommitted:    $(git status --short 2>/dev/null | head -10 || echo "none")
Latest plan:    $(ls ai/PLAN-M*.md 2>/dev/null | sort -V | tail -1 || echo "none found")
Recent commits: $(git log --oneline -5 2>/dev/null || echo "no commits")
```

Use this snapshot to orient immediately — do not re-read git status manually.

## Step 1 — Read the plan

Read the latest `ai/PLAN-M{n}.md` (identified above). Also read:
- `ai/LEARNINGS.md` — constraints you must not violate
- `ai/ARCHITECTURE.md` — architectural invariants
- `CLAUDE.md` — project non-negotiables

If `ai/PLAN-M{n}.md` does not exist, stop and ask the user to run `/plan-milestone` first.

## Step 2 — Define verification method (before writing any code)

**This step is non-negotiable. Do not skip it.**

Before touching any implementation file, state explicitly:

1. **Verification command** — the exact shell command you will run to confirm the milestone works
2. **Passing output** — what success looks like (exact counts, strings, or test output)
3. **Failure definition** — what would tell you something is wrong

Example:
> Verification: `pytest tests/ -v && python pipeline.py status --limit 5`
> Pass: all tests green, status shows 47 enriched records
> Fail: any test failure, or status shows 0 records

A milestone with no defined verification method cannot be executed. If the plan's "AI validation plan" section specifies these, copy them here verbatim. If it doesn't, define them now before proceeding.

## Step 3 — Implement

Follow the numbered steps in the Plan section exactly. For each step:
- Complete it fully before moving to the next
- If you discover the plan is wrong or incomplete: implement what you can, note the deviation, and flag it for the user at the end — do not silently improvise
- If you discover a structural problem that must be fixed first: stop, report it, propose a path forward

**Minimum user interaction during implementation.** Validate autonomously. Only surface blockers that truly require human input (OAuth, hardware, external accounts).

## Step 4 — Run verification

Run the exact command you defined in Step 2. Record exact outputs.

Required at minimum for any milestone:
- `pytest tests/` passes (no regressions)
- The primary CLI command runs live (`--limit 5` or equivalent, not just mocked tests)
- `python pipeline.py status` (or equivalent) shows expected stage counts
- Any output files open and are valid (not corrupt, not empty)

If verification fails: diagnose the root cause, fix, re-run. Do not mark done with a failing test. Do not move on.

## Step 5 — Fill in validation results

Update the **AI validation results** section of `ai/PLAN-M{n}.md` with:
- Exact commands run
- Exact outputs (counts, file names, any errors)
- Any deviations from the plan and why

This must be done before PM Review — the PM reads this section to understand what was actually built.

## Step 6 — PM Review

Run `/review-milestone` now. This is non-negotiable — do not skip it.

The PM review runs after validation results are documented, before commit. It checks the milestone from a commercial and user perspective, not a developer perspective. Follow the full `/review-milestone` protocol:
- REQUIRED issues (high conviction): fix autonomously, document in `ai/PLAN-M{n}.md`, re-test
- CLARIFY issues (low conviction): batch questions to the project owner, wait for answers before acting

Only proceed to Step 7 once the PM review verdict is PASS (either originally or after amendments).

## Step 7 — Better engineering phase

After verification passes, do the following before committing:

**(a) Run code simplifier**
Invoke the `/simplify` subagent on the files changed in this milestone. Accept any improvements that don't change external behavior. This runs after verification (code is confirmed working) and before commit (so simplifications are included in the milestone commit).

**(b) Update `ai/LEARNINGS.md`**
Hard limit: **25 lines of content**. This file is loaded into every session — token cost is real.

What belongs here: things not derivable from reading the code, that would cost a developer 30+ minutes to rediscover. One sentence per lesson, plus one sentence fix.

What does NOT belong here:

| Content | Where it belongs |
|---------|-----------------|
| Invariants that must never be violated | `CLAUDE.md` non-negotiables |
| Data flow, schema, component contracts | `ai/ARCHITECTURE.md` |
| Process rules, behavioral feedback | memory (`feedback_*.md`) |
| Things obvious from reading the code | Delete — don't write them |

At every milestone: **add new lessons AND prune stale ones**. If a lesson is now in the code or architecture docs, delete it here. The file should shrink as the project matures — that is a sign of good engineering, not neglect.

**(c) Update `ai/ARCHITECTURE.md`**
- Reflect any architectural decisions made or changed during this milestone
- Update invariants if they changed
- Remove anything stale

**(d) Update `ai/ROADMAP.md`**
- Mark this milestone complete with date
- Update "Current state" block (5 lines max)
- Flag any new open issues or deferred items discovered during implementation

**(e) Self-review checklist** — all must be true before committing:
- [ ] Type hints on all new function signatures
- [ ] No hardcoded values — all constants flow from config/settings
- [ ] `--dry-run` works on all commands that hit external APIs
- [ ] `pytest tests/` passes
- [ ] Output files valid (no corrupt Excel, empty HTML, broken JSON)
- [ ] `PLAN-M{n}.md` AI validation results section filled
- [ ] `PLAN-M{n}.md` PM Review section filled (PASS or CONDITIONAL PASS resolved)
- [ ] `ARCHITECTURE.md` / `LEARNINGS.md` updated if any design decision changed
- [ ] `ROADMAP.md` current state block updated
- [ ] `/simplify` run on changed files

## Step 8 — Commit

Stage and commit: implementation files + tests + plan file (with results + PM review) + updated docs.
One commit per milestone. Do not batch with other milestones.

## Step 9 — Present to user

Tell the user:
1. What was built (1–2 sentences)
2. The verification results (counts, test output)
3. PM review verdict — PASS or what was amended
4. Any deviations from the original plan
5. What to try (exact commands/steps for manual verification)
6. What the next milestone is

Mark the milestone ✅ in `ai/PLAN.md` only after all checklist items above are confirmed true.
