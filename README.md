# project-methodology

A reusable Claude Code skill set for building structured software projects with AI assistance.

Derived from the ALLEX pipeline build (Repuro, March 2026). Combines patterns from [ljw1004/oneplay](https://github.com/ljw1004/oneplay) with lessons learned building a production AI-powered lead generation pipeline.

---

## What this is

Five Claude Code slash commands — three for the core milestone loop, two for quality enforcement:

| Command | When to use |
|---------|------------|
| `/new-project` | Starting a new project — scaffolds all documentation files and fetches templates |
| `/plan-milestone` | Planning a specific milestone — full research, clarification, and decision-complete plan |
| `/execute-milestone` | Executing an approved plan — implementation, validation, simplification, documentation update |
| `/audit-security` | Security review — OWASP top 10 check on changed files or full codebase, with fix protocol |
| `/write-tests` | Test generation — fills coverage gaps for existing code, follows project test patterns |

Plus a `templates/` directory with the standard project file structure:
- `CLAUDE.md` — AI instruction file (always loaded)
- `ai/PLAN.md` — master plan with planning/execution protocols
- `ai/ARCHITECTURE.md` — system design and invariants
- `ai/DESIGN.md` — product logic (classification rules, filters, output schema)
- `ai/LEARNINGS.md` — durable engineering lessons (grows over time)

---

## Install (one-time, per machine)

```bash
bash <(curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/install.sh)
```

What it does:
- Downloads `/new-project`, `/plan-milestone`, `/execute-milestone` into `~/.claude/commands/`
- Downloads `update-skills.sh` into `~/.claude/`
- Adds a `Stop` hook to `~/.claude/settings.json` so skills auto-update daily in the background
- Seeds the ETag cache so the first auto-update check is instant

Requires: [Claude Code](https://claude.ai/code) + Python 3.6+ (for settings.json merge).

---

## Usage

**Starting a new project:**
```
/new-project
```
Claude asks 5 questions about your project, fetches the template files, customizes them, and drafts the first milestone plan.

**Planning a milestone:**
```
/plan-milestone
```
Claude reads all project documentation, researches the codebase, asks clarifying questions, and writes a decision-complete `ai/PLAN-M{n}.md`.

**Executing an approved plan:**
```
/execute-milestone
```
Claude implements the plan, validates autonomously, updates documentation, and commits.

---

## The methodology in one paragraph

Projects are built milestone by milestone. Each milestone has a planning phase (`/plan-milestone`) producing a decision-complete `PLAN-M{n}.md`, and an execution phase (`/execute-milestone`) that implements, validates, updates documentation, and commits — all in one atomic unit. The milestone is not done until tests pass, a live run completes, and docs are updated. A `LEARNINGS.md` file accumulates hard-won lessons across sessions. `ARCHITECTURE.md` tracks the stable system truth. `DESIGN.md` captures product logic. `CLAUDE.md` governs AI behavior. Nothing is implicit.

---

## Architecture principles

Every project built with this methodology inherits these defaults (non-negotiable):

1. **State store is a database, not CSV files.** No CSV as intermediate state.
2. **Separate cache from state.** HTTP/API cache in its own DB. Pipeline state in another.
3. **Every command is idempotent.** Re-running skips already-processed records.
4. **`--dry-run` on everything that touches external APIs.**
5. **One milestone = one commit = one `PLAN-M{n}.md`.** No batch commits.
6. **Forward-only schema migrations.** `ALTER TABLE ADD COLUMN` only.
7. **Prompts to AI subprocesses via stdin, not CLI args.** Special characters break shell quoting.
8. **Free steps before paid steps.** Cache before API. Keyword filter before AI call.
9. **`LEARNINGS.md` grows every session.** Never let a lesson go undocumented.
10. **Commit immediately after every meaningful change.** Sync scripts can wipe stash.

---

## File structure reference

```
project-root/
├── CLAUDE.md                    # Always-loaded AI instructions
├── ai/
│   ├── PLAN.md                  # Master plan + milestone table + protocols
│   ├── PLAN-M1.md               # M1 milestone document (created per milestone)
│   ├── PLAN-M2.md               # ...
│   ├── ARCHITECTURE.md          # How the system is built
│   ├── DESIGN.md                # What the system decides
│   ├── LEARNINGS.md             # Durable engineering lessons
│   └── ROADMAP.md               # Current state + next milestones + open issues
└── [project code]
```

---

## Inspired by

- [ljw1004/oneplay](https://github.com/ljw1004/oneplay) — `AGENTS.md` + `LEARNINGS.md` + milestone planning protocol
- ALLEX (Repuro lead pipeline) — production lessons from a 15-milestone AI-assisted build
- Boris Cherney (Claude Code) — inline bash context injection, pre-defined verification, PostToolUse formatting hooks
