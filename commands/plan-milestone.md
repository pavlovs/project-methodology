# /plan-milestone

You are entering **milestone planning mode**. Follow this protocol exactly. Do not skip steps.

## Step 1 — Orient (read before anything else)

Read in this order:
1. `ai/PLAN.md` — master milestone list and project vision
2. `ai/ROADMAP.md` — next milestones with scope, rationale, dependencies, and estimated effort (if it exists)
3. All existing `ai/PLAN-M{k}.md` files (prior milestone documents)
4. `ai/ARCHITECTURE.md` — current architecture and invariants
5. `ai/LEARNINGS.md` — hard-won lessons. Violations of these are bugs in your plan.
6. `CLAUDE.md` — project constraints and non-negotiables

If any of these files don't exist yet, note the gap and proceed with what's available.

## Step 2 — Understand the milestone

From the context you just read, identify:
- What milestone number is being planned (M{n})
- What the milestone is meant to deliver (from PLAN.md description)
- What the previous milestone left behind (starting state)
- What the next milestone needs (ending state to target)

## Step 3 — Research before asking

Before asking any clarifying question, do your own research:
- **Discoverable facts** (answer from the codebase): run searches, read files, check schemas. Never ask "where is X?" if you can find it. If multiple plausible candidates exist, present them and recommend one.
- **Preferences and tradeoffs** (cannot be discovered): ask these. Phrase each question with full context, tradeoffs, 2–4 concrete options, and your recommendation. A good question is 2–5 sentences.

Rule: if any high-impact ambiguity remains after research, ask before planning. Do not guess on things that materially change the spec.

## Step 4 — Write `ai/PLAN-M{n}.md`

Use this exact structure:

```
# M{n}: {title}

## Summary
{1–3 sentences: what this milestone delivers and how you know it's done}

## HOW TO EXECUTE THIS MILESTONE
{Copy the execution protocol from ai/PLAN.md verbatim here, so the executor has it without needing to read PLAN.md}

## Locked decisions
{Every decision made by the user or derived from research. Nothing ambiguous here.}

## Plan
{Numbered implementation steps. Specific enough that another engineer or agent can execute with zero further decisions.
Include: files to create/modify, function signatures, schema changes, API contracts, data flow.
Mark steps that require external API calls and their dry-run behavior.}

## Better engineering notes
{Architectural insights discovered during planning. Deferred cleanups. Future risks.}

## AI validation plan
{Exact commands to run. Expected outputs. How the executor knows the milestone is complete.
Must include: unit tests pass, live CLI run with --limit 5 (or equivalent), status command shows expected counts.}

## AI validation results
{Leave blank — filled by the executor}

## User validation walkthrough
{Step-by-step: what the user should run, click, or observe to verify the milestone themselves}
```

**Quality bar**: the plan must be **decision-complete**. The executor should not need to make any decisions. If you find yourself writing "the implementer should decide..." that is a planning failure — resolve it now.

## Step 5 — Check for engineering blockers

Ask: does this milestone require fixing something structural first? If yes:
- Small fix (< 1 day): include as Phase 0 in the plan
- Large fix (its own milestone): stop, tell the user, propose a new blocking milestone before M{n}

The user is always glad to hear about better engineering opportunities. Never paper over structural problems to hit a milestone faster.

## Step 6 — Validate the plan against LEARNINGS.md

Re-read `ai/LEARNINGS.md`. For each lesson, verify your plan doesn't violate it. If it does, fix the plan.

## Step 7 — Present for signoff

Show the user `ai/PLAN-M{n}.md`. State:
1. Any remaining open questions (batched — one ask, not multiple interruptions)
2. Any risks or assumptions baked into the plan
3. What you need from the user to proceed

Do not begin execution until the user explicitly approves.
