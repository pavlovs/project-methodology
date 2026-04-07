# /review-milestone

You are entering **PM review mode**. This runs after milestone tests pass and validation results are filled in `ai/PLAN-M{n}.md`, before commit.

## Step 1 — Identify active milestone

Determine which milestone is under review:
- If invoked from `/execute-milestone`: the milestone currently being executed
- If invoked standalone: find the latest `ai/PLAN-M*.md` file. If multiple candidates exist (e.g. two files with no PM Review section), ask the project owner which one to review before proceeding

## Step 2 — Select review model

Collect the following before proceeding:
- Full path to `ai/PLAN-M{n}.md` (the active milestone)
- Full path to `ai/DESIGN.md` (skip if not present)
- Full path to `CLAUDE.md`
- Full path to `ai/PLAN.md`
- Current working directory

### Step 2a — Check for external review capability

Check in order:
1. Is `OPENAI_API_KEY` set in the environment?
2. Is `codex` CLI available (`command -v codex`)?

If **either is available**: proceed to Step 2b (external model review).
If **neither is available**: fall back to Step 2e (Opus sub-agent, same as v2).

### Step 2b — Prepare review context (external model path)

Read all four files and concatenate into a single review prompt. Use this structure:

```
You are a senior product manager and commercial decision-maker reviewing a software milestone.
Review from a user and business perspective — not code quality.

=== MILESTONE PLAN AND VALIDATION RESULTS ===
{full content of ai/PLAN-M{n}.md}

=== PRODUCT DESIGN ===
{full content of ai/DESIGN.md, or "No DESIGN.md present — note this gap"}

=== PROJECT CONSTRAINTS ===
{full content of CLAUDE.md — truncate to first 100 lines if longer}

=== PROJECT VISION ===
{Summary and milestone table from ai/PLAN.md — not the full file}

=== REVIEW INSTRUCTIONS ===
{Copy the PM Review instructions section below (Steps 3–6) verbatim}

Output your review in the exact format specified in the instructions.
```

Write this to a temporary file (e.g., `/tmp/pm-review-prompt.txt`).

### Step 2c — Call external model

Run the external review script:
```bash
bash ~/.claude/scripts/external-review.sh /tmp/pm-review-prompt.txt
```

The script reads `OPENAI_API_KEY` and `EXTERNAL_REVIEW_MODEL` (default: `o3`) from the environment. It returns the model's response as text, or exits non-zero on failure.

If the script fails (non-zero exit): log the error and fall back to Step 2e (Opus sub-agent).

### Step 2d — Parse response and write PM Review block

Read the external model's response. Extract:
- Required changes section
- Clarify with project owner section
- Verdict (PASS or CONDITIONAL PASS)

Write the `## PM Review` block to `ai/PLAN-M{n}.md` using the format specified in the PM Review instructions below. Set the `Model:` line to the actual model used (e.g., `Model: o3 (OpenAI, external review)`).

If the response doesn't follow the expected format: extract what you can, note formatting issues in the review block, and proceed.

Then proceed to Step 3 to execute the verdict.

### Step 2e — Opus sub-agent fallback

If no external model is configured, or the external call failed:

Spawn a dedicated Opus sub-agent:
- `subagent_type`: `general-purpose`
- `model`: `opus`
- Prompt: pass the full PM review instructions below (Steps 3–6) along with the file paths

The sub-agent reads the files, performs the review, writes the `## PM Review` block to `ai/PLAN-M{n}.md` with `Model: claude-opus-4-6 (fallback — no external model configured)`, and returns its verdict.

Once the sub-agent returns: read its output, then proceed to Step 3 to execute the verdict.

---

## PM Review instructions (for the reviewer — external model or Opus sub-agent)

### Load context

Read in order:
1. `ai/PLAN-M{n}.md` — what was planned, what was built, and the AI validation results (if the results section is blank, stop and report this — the calling session must fill it first)
2. `ai/DESIGN.md` — product logic, output schema, who uses this (skip if not present — note the gap in your output)
3. `CLAUDE.md` — project constraints, stack, non-negotiables
4. `ai/PLAN.md` — overall vision and project goals

### Review

Act as a senior product manager and commercial decision-maker with deep industry knowledge in the project's domain. You are not reviewing code quality. Review from a user and business perspective.

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

### Classify each issue

Assign every finding to exactly one tier. Apply strictly — do not promote low-conviction findings to REQUIRED.

**REQUIRED** (high conviction):
- Clear functional gap: feature was stated in the milestone summary and is missing
- Silent wrong behavior: output is incorrect with no error or warning raised
- Data loss / corruption risk: pipeline could skip, duplicate, or corrupt records
- Obvious UX failure: a real non-developer user would be immediately stuck or misled

**CLARIFY** (uncertain or judgment call):
- Output format or wording choices where reasonable people disagree
- Scope ambiguity: unclear whether this was intended to be in this milestone
- Architectural tradeoffs with no objectively correct answer
- Anything where the fix might change intended behavior in non-obvious ways
- Cases where you are genuinely unsure if something is a bug or a design decision

If uncertain which tier an issue belongs to: assign it to CLARIFY.

### Write PM Review block

Append a `## PM Review` section to `ai/PLAN-M{n}.md`. Do not skip this even on a clean PASS.

```
## PM Review
Reviewed: {date}
Model: {model_used}

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

Return to the calling session: state the verdict, list all findings by tier, and confirm the review block was written to `ai/PLAN-M{n}.md`.

---

## Step 3 — Execute by verdict

Once the reviewer returns its verdict, the calling session takes over.

**PASS** (both lists empty): report clean pass. Return control to the `/execute-milestone` flow.

**CONDITIONAL PASS**:

_REQUIRED changes — autonomous execution (calling session):_
1. Add a `### PM Amendments` section to `ai/PLAN-M{n}.md` listing each change as a numbered implementation step
2. Execute each step with the same rigor as regular milestone execution
3. Re-run full verification: `pytest tests/` + live CLI run
4. Add a `### PM Amendment Results` section to `ai/PLAN-M{n}.md` with exact commands and outputs
5. Re-run the review using the same model path as the initial review (one re-review cycle maximum)
6. If clean on re-review: update the `### Verdict` line to PASS and return to the `/execute-milestone` flow
7. If REQUIRED issues still exist after one cycle: stop, surface all remaining issues to the project owner. Do not commit.

_CLARIFY items — requires project owner input:_
1. Batch all questions into a single message — do not ask one at a time
2. For each: state the issue, the uncertainty, concrete options, your recommendation
3. Wait for the project owner's response before implementing any of them
4. After decisions are given: implement, document each decision in `ai/PLAN-M{n}.md`, re-run tests
