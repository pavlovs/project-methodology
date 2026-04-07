# Architecture — {Project Name}

## System Overview

{Diagram or prose. Describe the linear data flow, primary components, and where state lives.}

```
[Source A]    [Source B]
     │              │
     ▼              ▼
  [INGEST / NORMALIZE]
          │
          ▼
     [primary.db]   ← single source of truth for all pipeline state
          │
     [FILTER]       ← pre-qualification, no API cost
          │
     [SCRAPE / FETCH] ← external HTTP; results cached in knowledge_base.db
          │
     [CLASSIFY / PROCESS] ← AI or rule-based; reads from DB, writes back
          │
     [ENRICH]       ← paid APIs (A/B only, cache-first)
          │
     [EXPORT]       ← final output file(s)
          │
     [DASHBOARD]    ← read/write interface
```

---

## Data Flow

{Describe each stage: what it reads, what it writes, what it skips. 1–3 sentences per stage.}

---

## Module Responsibilities

| Module | Responsibility |
|--------|---------------|
| `src/pipeline/ingest.py` | Normalize all sources → DB |
| `src/pipeline/filter.py` | Pre-qualification filters |
| `src/pipeline/scrape.py` | HTTP fetch → knowledge base cache |
| `src/pipeline/classify.py` | AI classification |
| `src/pipeline/enrich.py` | Ownership + contact enrichment |
| `src/pipeline/export.py` | Output file generation |
| `src/pipeline/dashboard.py` | HTML + local HTTP server |
| `src/config/settings.py` | All constants, paths, thresholds |
| `src/utils/web.py` | HTTP retry, SSL, extract text |

---

## Data Sources

{Populated during project setup from Step 1b answers. Describes what enters the system and where it comes from.}

| Source | Format | Volume | Update frequency | Notes |
|--------|--------|--------|-----------------|-------|
| {source 1} | {CSV/API/DB/manual} | {records/day or total} | {once/daily/realtime} | {access method, auth, known quirks} |
| {source 2} | {format} | {volume} | {frequency} | {notes} |

---

## Data Model

### Primary state store (`data/primary.db`)

```sql
CREATE TABLE records (
    id              TEXT PRIMARY KEY,   -- md5(domain)[:12]
    domain          TEXT UNIQUE NOT NULL,
    full_name       TEXT,
    pipeline_stage  TEXT,               -- ingested/filtered/scraped/classified/enriched/exported
    -- ... add fields as milestones are built
    ingested_at     TEXT,
    updated_at      TEXT
);
```

### Knowledge base cache (`data/knowledge_base.db`)

```sql
CREATE TABLE domain_cache (
    domain      TEXT PRIMARY KEY,
    scraped_text TEXT,
    scraped_at  TEXT,
    http_status INTEGER
);
```

---

## Key Invariants

These must always be true. Violations are bugs.

- `id = md5(domain.encode())[:12]` — stable across all runs
- `pipeline_stage` tracks exact position in pipeline — never skip stages
- Every command is idempotent — re-running skips already-processed records
- Knowledge base is append-only — never delete cached entries
- Source input files are NEVER modified — read-only
- All API-touching commands support `--dry-run`
- Prompts passed to AI subprocesses via stdin, not CLI args (special chars break shell quoting)
- Schema migrations are forward-only: `ALTER TABLE ADD COLUMN` only. Never drop or rename.

---

## External Dependencies

| Service | Used for | Tier | Credits/Cost |
|---------|----------|------|-------------|
| Claude API | AI classification | Haiku (bulk) / Sonnet (quality) | ~€0.001–0.01/record |
| {Service 2} | {purpose} | {tier} | {cost} |

---

## HTTP Layer

{Describe retry logic, timeout strategy, SSL handling, rate limiting if relevant.}
Key decisions:
- Split timeout: `connect={X}s, read={Y}s` — {why}
- SSL fallback: verify-on → verify-off for broken certs
- DNS failure: immediate exit, no retry, mark as failed

---

## Profile / Config Schema

{If project is profile-driven (configurable for different clients/industries):}

```json
{
  "id": "profile_id",
  "name": "Human-readable name",
  "filters": {},
  "classification": { "target_description": "", "examples": [] },
  "export": {}
}
```

---

## Comparable Projects

{Added during milestone execution (Step 7b). 1-2 open-source projects in the same domain for reference.}

| Project | What's similar | Key difference | Link |
|---------|---------------|----------------|------|
