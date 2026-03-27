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

## Step 6 — Better engineering phase

After verification passes, do the following before committing:

**(a) Run code simplifier**
Invoke the `/simplify` subagent on the files changed in this milestone. Accept any improvements that don't change external behavior. This runs after verification (code is confirmed working) and before commit (so simplifications are included in the milestone commit).

**(b) Update `ai/LEARNINGS.md`**
- Add any new durable lessons (things that would cost a future developer time if unknown)
- Remove anything that's now better documented in code or architecture
- Follow the scope ladder: repo-wide wisdom → LEARNINGS.md; app-specific policy → ARCHITECTURE.md; symbol-local → code comments

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
- [ ] `ARCHITECTURE.md` / `LEARNINGS.md` updated if any design decision changed
- [ ] `ROADMAP.md` current state block updated
- [ ] `/simplify` run on changed files

## Step 7 — Commit

Stage and commit: implementation files + tests + plan file (with results) + updated docs.
One commit per milestone. Do not batch with other milestones.

## Step 8 — Present to user

Tell the user:
1. What was built (1–2 sentences)
2. The verification results (counts, test output)
3. Any deviations from the plan
4. What to try (exact commands/steps for manual verification)
5. What the next milestone is

Mark the milestone ✅ in `ai/PLAN.md` only after all checklist items above are confirmed true.
