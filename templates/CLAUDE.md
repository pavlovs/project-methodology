# {Project Name}

{One-line description of what this project does and why.}

## Core Working Principles
1. Invoke multiple independent operations simultaneously where possible.
2. Verify solutions before finishing — run the CLI, check output files.
3. Do exactly what's asked — nothing more, nothing less.
4. Never create unnecessary files.
5. Prefer editing existing files over creating new ones.
6. Project structure is in `./ai/ARCHITECTURE.md`.
7. Master plan and milestones are in `./ai/PLAN.md` and `./ai/PLAN-M{n}.md`.
8. Product logic (classification, filters, output schema) is in `./ai/DESIGN.md`.

## Project Stack
- **Language**: {e.g. Python 3.11+}
- **Data I/O**: {e.g. pandas, openpyxl}
- **Web scraping**: {e.g. requests, beautifulsoup4}
- **AI classification**: {e.g. claude CLI subprocess (--via-cli) for bulk; anthropic SDK fallback}
- **CLI**: {e.g. argparse (stdlib)}
- **Testing**: {e.g. pytest}
- **Config**: {e.g. python-dotenv, .env file}

## Architecture — One-Line Summary

{e.g. Ingest → Filter → Scrape → Classify → Enrich → Export → Dashboard}

Full architecture: see `./ai/ARCHITECTURE.md`

## Architecture — Non-Negotiable Decisions
- **Primary state store is SQLite (`data/primary.db`), not CSV files.** All pipeline stages read and write to this DB. Never replace with CSV staging files.
- **CSV files are input-only or final output only.** No intermediate CSVs.
- **`settings.py` must always contain `PRIMARY_DB_PATH`.** If you see CSV staging path constants there, that is an error — remove them.
- **`{entrypoint}.py status` reads from the DB.** Never rewrite it to read CSV files.

## Critical Constraints
- **Never call paid APIs in bulk without a dry-run flag first.** Always implement `--dry-run` on any command that hits external APIs.
- **Never write to source input files.** They are read-only. All output goes to `data/output/`.
- **API keys must come from `.env`** — never hardcoded.
- **Encoding**: always specify `encoding="utf-8"` on file operations.
- **Prompts to AI subprocesses via stdin, not CLI args.** Real data contains special characters that break shell quoting.

## Classification System (if applicable)
- **A** = {describe}
- **B** = {describe}
- **C** = Unclear — flag for manual review
- **D** = Clear no-fit — exclude, log reason

Full classification logic: see `./ai/DESIGN.md`

## CLI Entry Point
All commands run via `python {entrypoint}.py <command> [options]`

```bash
python {entrypoint}.py ingest      # Load all source data → DB
python {entrypoint}.py filter      # Apply hard pre-qualification filters
python {entrypoint}.py scrape      # Fetch external content
python {entrypoint}.py classify    # AI classification
python {entrypoint}.py enrich      # Enrichment (paid APIs, A/B only)
python {entrypoint}.py export      # Generate output files
python {entrypoint}.py dashboard   # HTML dashboard
python {entrypoint}.py status      # Show pipeline state and counts
```

All commands support `--dry-run` and `--verbose`.

## Development Commands
```bash
pip install -r requirements.txt
pytest tests/
python {entrypoint}.py status
python {entrypoint}.py ingest --dry-run
```

## Code Quality Standards
- **No hardcoded values** — use `src/config/settings.py` constants
- **No silent failures** — all API errors caught, logged, re-raisable
- **Logging**: use Python `logging` module, not print statements
- **Type hints**: all function signatures must have type hints

## Key File Paths
```
{entrypoint}.py              # CLI entry point
src/pipeline/ingest.py       # Data ingestion and deduplication
src/pipeline/filter.py       # Pre-qualification hard filters
src/pipeline/scrape.py       # External content extraction
src/pipeline/classify.py     # AI classification
src/pipeline/enrich.py       # Enrichment
src/pipeline/export.py       # Output file generation
src/pipeline/dashboard.py    # HTML dashboard
src/config/settings.py       # Constants, thresholds, paths
data/input/                  # Source files (read-only)
data/output/                 # Final deliverables
data/primary.db              # Primary pipeline state (SQLite)
data/knowledge_base.db       # HTTP + API cache (SQLite, never deleted)
```

## Definition of Done — Hard Gate

A milestone is NOT complete until:
1. `ai/PLAN-M{n}.md` exists with `## AI VALIDATION RESULTS` filled in
2. `pytest tests/` passes
3. CLI command ran live (`--limit 5`) against real data
4. Status command shows expected counts
5. If schema, output format, or prompt changed: docs updated in same commit
6. One commit per milestone — no batch commits
