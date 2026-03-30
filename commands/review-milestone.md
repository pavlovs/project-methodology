# /review-milestone

You are entering **PM review mode**. This runs after milestone tests pass and validation results are filled in `ai/PLAN-M{n}.md`, before commit.

## Step 1 — Identify active milestone

Determine which milestone is under review:
- If invoked from `/execute-milestone`: the milestone currently being executed
- If invoked standalone: find the latest `ai/PLAN-M*.md` file. If multiple candidates exist (e.g. two files with no PM Review section), ask the project owner which one to review before proceeding

## Step 2 — Model check (hard gate)

Check which model is currently active. You have this in your context.

**If running on Opus**: note it and proceed to Step 3.

**If NOT running on Opus**: stop and present this to the user:

> PM Review is optimized for Opus — deeper commercial reasoning and better domain-specific edge-case detection.
> You are currently on: **[state the model]**
>
> Choose before I proceed:
> **[A] Switch to Opus** — type `/model opus`, start a new session, then re-run `/review-milestone`
> **[B] Continue on [current model]** — review proceeds; note that some nuance may be missed

Do not proceed to Step 3 until the user responds.

## Step 3 — Load context

Read in order:
1. `ai/PLAN-M{n}.md` — what was planned, what was built, and the AI validation results (must be filled — if the results section is blank, stop and ask the project owner to fill it first)
2. `ai/DESIGN.md` — product logic, output schema, who uses this (skip gracefully if not present — note the gap)
3. `CLAUDE.md` — project constraints, stack, non-negotiables
4. `ai/PLAN.md` — overall vision and project goals

## Step 4 — Review

Act as a senior product manager and commercial decision-maker with deep industry knowledge in the project's domain. You are not reviewing code quality — that is the developer's job. Review from a user and business perspective.

**Correctness of behavior**
- Does the milestone deliver exactly what was promised in its summary?
- Are there cases where the system silently produces wrong output — no error, wrong result?
- Does the actual output match the schema and format defined in DESIGN.md (if present)?

**User experience**
- Would a real user understand the output without developer context?
- Are error messages and edge-case outputs human-readable?
- Is the output format what a user actually needs — or what was technically convenient?

**Commercial completeness**
- What would a real user hit on day 1 that causes a manual workaround?
- What's missing that would generate a support request?
- Is the happy path covering realistic inputs, or only the ideal case?

**Edge cases**
- Empty input, malformed data, missing required fields — what happens?
- Partial pipeline state — what if a prior stage wrote partial data?
- What happens at 10x expected volume or with unexpected encoding?

## Step 5 — Classify each issue

Assign every finding to exactly one tier. Apply the tiers strictly — do not promote low-conviction findings to REQUIRED.

**REQUIRED** (high conviction → fix autonomously, document everything):
- Clear functional gap: feature was stated in the milestone summary and is missing
- Silent wrong behavior: output is incorrect with no error or warning raised
- Data loss / corruption risk: pipeline could skip, duplicate, or corrupt records
- Obvious UX failure: a real non-developer user would be immediately stuck or misled

**CLARIFY** (uncertain or judgment call → ask the project owner before acting):
- Output format or wording choices where reasonable people disagree
- Scope ambiguity: unclear whether this was intended to be in this milestone
- Architectural tradeoffs with no objectively correct answer
- Anything where the fix might change intended behavior in non-obvious ways
- Cases where you are genuinely unsure if something is a bug or a design decision

If uncertain which tier an issue belongs to: assign it to CLARIFY.

## Step 6 — Write PM Review block

Append a `## PM Review` section to `ai/PLAN-M{n}.md`. Do not skip this even on a clean PASS.

```
## PM Review
Reviewed: {date}
Model: {model that ran this review}

### Required changes (high conviction — autonomous)
{numbered list, or "None"}
Each item:
- **Issue**: [what is wrong]
- **User impact**: [what a real user experiences]
- **Fix**: [specific change — precise enough to implement without further discussion]

### Clarify with project owner (low conviction)
{numbered list, or "None"}
Each item:
- **Issue**: [what is unclear or debatable]
- **Uncertainty**: [why this is a judgment call, not a clear bug]
- **Options**: [A] ... / [B] ...
- **Recommendation**: [your preference and why]

### Verdict
PASS | CONDITIONAL PASS
```

## Step 7 — Execute by verdict

**PASS** (both lists empty): report clean pass. Return control to the `/execute-milestone` flow.

**CONDITIONAL PASS**:

_REQUIRED changes — autonomous execution:_
1. Add a `### PM Amendments` section to `ai/PLAN-M{n}.md` listing each change as a numbered implementation step
2. Execute each step with the same rigor as regular milestone execution
3. Re-run full verification: `pytest tests/` + live CLI run
4. Add a `### PM Amendment Results` section to `ai/PLAN-M{n}.md` with exact commands and outputs
5. Run PM review once more (Steps 4–5 above) — one re-review cycle maximum
6. If clean on re-review: update the `### Verdict` line to PASS and return to the `/execute-milestone` flow
7. If REQUIRED issues still exist after one cycle: stop, surface all remaining issues to the project owner. Do not commit.

_CLARIFY items — requires project owner input:_
1. Batch all questions into a single message — do not ask one at a time
2. For each: state the issue, the uncertainty, concrete options, your recommendation
3. Wait for the project owner's response before implementing any of them
4. After decisions are given: implement, document each decision in `ai/PLAN-M{n}.md`, re-run tests
