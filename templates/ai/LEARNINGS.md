# Learnings — {Project Name}

Durable engineering wisdom for this project, built up over time through trial and error.

**Scope ladder — where to put a new insight:**
- **Repo-wide and durable** (survives refactors, applies across components): put it here
- **App-specific architecture/policy** (data flow, invariants, component contracts): `ai/ARCHITECTURE.md`
- **Symbol-local contract** (one function or type's behavior): code docblock near the symbol
- **Naming/API smell** (callers keep misusing something): rename the API, don't add prose
- Quick test: if it remains true after renaming modules and shipping new features → LEARNINGS.md

---

## Engineering discipline

{Add lessons here as you discover them. Examples from ALLEX:}

- **Never pass prompts as CLI arguments.** Use stdin (`input=prompt`). Real data contains `&`, `+`, newlines that break Windows shell quoting.
- **Auto-sync scripts destroy uncommitted work.** Commit immediately after every meaningful change. Stash is not a safety net.
- **Batch commits across milestones break documentation coherence.** One milestone = one commit = one PLAN-M{n}.md.

---

## Data architecture

{Add lessons here. Examples from ALLEX:}

- **Primary state store is SQLite, not CSV.** CSV staging files as intermediate state cause regressions and make re-runs ambiguous.
- **Schema migrations are forward-only.** `ALTER TABLE ADD COLUMN`. Never drop or rename. This prevents data loss on re-runs against existing databases.
- **Cache and state are separate databases.** Knowledge base = immutable HTTP cache. Pipeline DB = mutable state. Mixing them makes cache invalidation unsafe.

---

## API and external services

{Add lessons here. Examples from ALLEX:}

- **Free steps always before paid steps.** Keyword pre-filters before AI calls. Cache lookups before API calls.
- **Idempotency is a hard requirement.** Every command must skip already-processed records. Never re-process.
- **Dry-run on everything that touches external APIs.** Without it, accidental double-runs double spend.

---

## Testing

{Add lessons here.}

---

## Windows / platform specifics

{Add lessons here. Examples from ALLEX:}

- **cp1252 terminal encoding.** Use `encoding='utf-8'` on all file operations. Avoid `→` and other non-ASCII in terminal output strings — use `->` instead.
- **Claude CLI subprocess.** Use `claude.cmd` not `claude` on Windows. Pass prompt via `input=` (stdin), not positional argument.
