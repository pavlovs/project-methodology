# /new-project

Scaffold a new software project using the proven architecture from the ALLEX pipeline (Repuro, 2026).
Designed for Claude-assisted development: full documentation, milestone-based execution, growing learnings system.

## Step 1 — Understand the project

Ask the user these questions **all at once**:

1. **Project name and one-line description** — what does it do?
2. **Tech stack** — language, framework, primary data store, external APIs
3. **Output** — what does success look like? (CLI tool, web app, export file, API...)
4. **Scale constraints** — hard limits on cost, latency, or volume?
5. **Who runs it** — just the owner, a team, end users?

Do not proceed until you have answers.

## Step 2 — Fetch template files

Run the following in the project root to pull the standard templates from GitHub:

```bash
mkdir -p ai
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/CLAUDE.md > CLAUDE.md
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/PLAN.md > ai/PLAN.md
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/ARCHITECTURE.md > ai/ARCHITECTURE.md
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/DESIGN.md > ai/DESIGN.md
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/LEARNINGS.md > ai/LEARNINGS.md
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/ROADMAP.md > ai/ROADMAP.md
```

Verify all 7 files exist and are non-empty before proceeding.

## Step 3 — Customize every file

Replace all `{placeholders}` with real project content. Do not leave template text verbatim.

| File | What to fill in |
|------|----------------|
| `CLAUDE.md` | Project name, stack, CLI commands, non-negotiable decisions, key file paths |
| `ai/PLAN.md` | Vision, project goal, first 3–5 milestones in the table, initial current state block |
| `ai/ARCHITECTURE.md` | Data flow diagram, module responsibilities, DB schema, key invariants |
| `ai/DESIGN.md` | What the system looks for, classification rules, filter logic, output schema, AI prompt design |
| `ai/LEARNINGS.md` | Scope ladder is pre-filled; add any known platform/stack-specific lessons |

**What goes where (decision tree):**
- Product logic (what the system decides) → `ai/DESIGN.md`
- How the system is built (data flow, schema, modules) → `ai/ARCHITECTURE.md`
- Build sequence and planning/execution protocols → `ai/PLAN.md`
- Durable engineering lessons → `ai/LEARNINGS.md`
- AI behavior rules and hard constraints → `CLAUDE.md`

## Step 4 — Create `ai/ROADMAP.md`

Write a fresh ROADMAP.md for this project. It should include:
- **Foundation** — what's already set up (initially: just M1 Infrastructure)
- **Current state** — 5 lines max, updated at each session end
- **Next milestones** — M1 through M3 with rationale and dependencies
- **Deferred** — things explicitly not in scope yet, with reason
- **Open issues** — known unknowns or tech debt (initially empty)

## Step 5 — Draft `ai/PLAN-M1.md`

Immediately plan the infrastructure milestone:
- Development environment setup
- Project skeleton: entry point, config, tests passing
- CLI commands stubbed (all return "not implemented")
- "Close the loop" validation: can run end-to-end with dummy data, get sensible output

Use `/plan-milestone` for the full planning protocol.

## Step 6 — Set up formatting hook

Recommend the user configure a PostToolUse hook to auto-format code after every file write. This catches the last 10% of formatting issues before CI does. Ask what language/formatter applies:

| Stack | Formatter command |
|-------|------------------|
| Python | `ruff format {file}` or `black {file}` |
| TypeScript/JS | `prettier --write {file}` |
| Go | `gofmt -w {file}` |
| Rust | `rustfmt {file}` |

Add to `.claude/settings.json` (project-level, check into git):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "<formatter> \"$CLAUDE_TOOL_OUTPUT_FILE\""
          }
        ]
      }
    ]
  }
}
```

Skip this step if no formatter is available or the project has no consistent style tooling.

## Step 7 — Confirm and commit

Present the full file structure to the user. Ask:
1. Does the CLAUDE.md description match your intent exactly?
2. Are the non-negotiable architectural decisions correct?
3. Any milestones obviously missing from the PLAN.md table?
4. Does the formatter hook look right for your stack?

After approval: ensure `.gitignore` exists, make initial commit with all `ai/`, `CLAUDE.md`, and `.claude/settings.json` files.

---

## Architecture principles baked into every project from this template

Non-negotiable defaults derived from the ALLEX build (Repuro, March 2026):

1. **State store is a database, not CSV files.** SQLite for solo projects. No CSV as intermediate state between pipeline stages.
2. **Separate cache from state.** Expensive external API calls → dedicated cache DB or table. State DB tracks pipeline progress. Never mix them.
3. **Every command is idempotent.** Re-running produces the same result. Skip already-processed records. This is what makes the system debuggable.
4. **`--dry-run` on everything that touches external APIs.** No exceptions. Default to safe.
5. **One milestone = one commit set = one `PLAN-M{n}.md`.** No batch commits. This is how documentation stays coherent.
6. **Forward-only schema migrations.** `ALTER TABLE ADD COLUMN` only. Never drop or rename columns.
7. **Prompts via stdin, not CLI args.** When calling AI subprocesses, pass prompts via `input=` (stdin). Special characters in real data break shell quoting.
8. **Free steps before paid steps.** Keyword pre-filters before AI calls. Cache before API. Cost is a first-class constraint.
9. **`ai/LEARNINGS.md` is a living document.** Every session that uncovers a new lesson ends with an update.
10. **Commit immediately after every meaningful change.** Background sync scripts can wipe stash silently.
11. **PM Review is a hard gate after every milestone.** Run `/review-milestone` after tests pass. REQUIRED issues (high conviction) are fixed autonomously with documentation. CLARIFY issues are batched to the owner before acting. A milestone is not done until the PM review shows PASS.
