# /new-project

Scaffold a new software project using the proven architecture from the ALLEX pipeline (Repuro, 2026).
Designed for Claude-assisted development: full documentation, milestone-based execution, growing learnings system.

## Step 1a — Understand the project

Ask the user these questions **all at once**:

1. **Project name and one-line description** — what does it do?
2. **Tech stack** — language, framework, primary data store, external APIs
3. **Output** — what does success look like? (CLI tool, web app, export file, API...)
4. **Scale constraints** — hard limits on cost, latency, or volume?
5. **Who runs it** — just the owner, a team, end users?

Do not proceed until you have answers.

## Step 1b — Understand the domain and data

After receiving Step 1a answers, ask these questions **all at once**:

1. **Data sources** — What data enters the system? Where does it come from? (files, APIs, databases, user input, scraping). Be specific: file formats, API endpoints, database types, update frequency.
2. **Data structure** — What does a single record/entity look like? What are the key fields? What uniquely identifies a record? What relationships exist between entities?
3. **Data volume and lifecycle** — How much data at day 1? At month 6? Is data append-only, mutable, or versioned? What gets archived vs deleted?
4. **Domain expertise** — What domain knowledge is needed to build this correctly? Are there industry standards, regulatory requirements, or domain-specific terminology the AI must understand? Where does that knowledge live (docs, the user's head, external references)?
5. **Existing systems** — Does this replace or integrate with existing tools? What are the interfaces? Are there data migration requirements?

**Do not proceed to template customization until you have data structure answers.** These answers directly inform `ai/ARCHITECTURE.md` (Data Sources + Data Model sections) and `ai/DESIGN.md` (Domain Knowledge + classification logic).

## Step 2 — Copy template files from local methodology repo

Copy templates from the local project-methodology folder (kept in CLAUDE_COWORK):

```bash
METHODOLOGY_DIR="$HOME/Documents/CLAUDE_COWORK/project-methodology/templates"
mkdir -p ai
cp "$METHODOLOGY_DIR/CLAUDE.md" CLAUDE.md
cp "$METHODOLOGY_DIR/ai/PLAN.md" ai/PLAN.md
cp "$METHODOLOGY_DIR/ai/ARCHITECTURE.md" ai/ARCHITECTURE.md
cp "$METHODOLOGY_DIR/ai/DESIGN.md" ai/DESIGN.md
cp "$METHODOLOGY_DIR/ai/LEARNINGS.md" ai/LEARNINGS.md
cp "$METHODOLOGY_DIR/ai/ROADMAP.md" ai/ROADMAP.md
```

If the local methodology folder doesn't exist, fall back to GitHub:
```bash
curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/CLAUDE.md > CLAUDE.md
# ... (same for all other files)
```

Verify all 6 files exist and are non-empty before proceeding.

After copying, stamp the methodology version into the project's `CLAUDE.md`:
- Read the version from `~/.claude/.skill-cache/methodology-version` (written by install.sh)
- Replace `{version}` in the `<!-- project-methodology v{version} -->` footer with the actual version
- If the version file doesn't exist, stamp `unknown`

## Step 3 — Customize every file

Replace all `{placeholders}` with real project content. Do not leave template text verbatim.

| File | What to fill in |
|------|----------------|
| `CLAUDE.md` | Project name, stack, CLI commands, non-negotiable decisions, key file paths |
| `ai/PLAN.md` | Vision, project goal, first 3–5 milestones in the table, initial current state block |
| `ai/ARCHITECTURE.md` | Data flow diagram, module responsibilities, DB schema, key invariants. **Use the data structure answers from Step 1b** to populate the Data Sources table and Data Model section with the real schema — do not leave the template's generic placeholders |
| `ai/DESIGN.md` | What the system looks for, classification rules, filter logic, output schema, AI prompt design. **Use the domain expertise answers from Step 1b** to populate the Domain Knowledge section and glossary |
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

## Step 6 — Create project agents

Create `.claude/agents/` in the project root with two standard agents:

**`analyst.md`** — read-only diagnostic agent (Haiku, `memory: project`). Use for: status checks, data quality audits, schema questions, pipeline diagnostics. Never writes or modifies files. With `memory: project`, it accumulates project-specific knowledge across sessions (schema quirks, known edge cases, data patterns) — replacing manual LEARNINGS.md updates for operational detail.

**`executor.md`** — execution agent (Sonnet). Use for: running pipeline operations, applying data fixes, executing steps defined in PLAN-M{n}.md. Pre-execution checklist: read the plan, verify before-state, execute, verify after-state.

Both agents should read `ai/ARCHITECTURE.md` and `ai/LEARNINGS.md` at the start of their tasks.

Add a third agent if the project has external-facing output:

**`drafter.md`** — drafting agent (Opus). Use for: client-facing documents, reports, investor output. Loads brand-voice.md before drafting.

Commit the agents with the initial project scaffold.

## Step 7 — Set up formatting hook

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
