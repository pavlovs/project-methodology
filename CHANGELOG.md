# Changelog

## v3.0.0

- **Cross-model PM review**: `/review-milestone` can now dispatch to an external model (OpenAI) for independent perspective. Falls back to Opus if no API key configured.
- **Version tracking**: methodology version stamped into every project's `CLAUDE.md`. Install and auto-update are version-aware. Templates fetched by tag, not `main`.
- **Domain-knowledge discovery**: `/new-project` now asks data source, data structure, volume, and domain expertise questions before template customization. New `Data Sources` section in ARCHITECTURE.md template, `Domain Knowledge` section in DESIGN.md template.
- **Architecture-first improvement**: `/execute-milestone` Step 7 reordered — data structure review runs before code simplification. New comparable project search step.

## v2.0.0

- **PM review gate**: `/review-milestone` skill — spawns Opus sub-agent for commercial/UX review after tests pass. Two-tier verdict (REQUIRED auto-fix, CLARIFY ask owner).
- **Project agents**: `/new-project` creates analyst, executor, and drafter agents in `.claude/agents/`.
- **Plan mode**: `/plan-milestone` runs in read-only plan mode with Opus model recommendation.
- **Stakeholder name verification**: prevents hallucinated names from bleeding across projects.
- **Local template copy**: `/new-project` copies from local repo first, falls back to GitHub.
- **Security and test skills**: `/audit-security` (OWASP top 10) and `/write-tests` (coverage gap fill).

## v1.0.0

- Initial release: `/new-project`, `/plan-milestone`, `/execute-milestone` skills.
- Template set: CLAUDE.md, PLAN.md, ARCHITECTURE.md, DESIGN.md, LEARNINGS.md, ROADMAP.md.
- Install script with auto-update via Stop hook and ETag cache.
- Architecture principles: SQLite state store, idempotent commands, dry-run, forward-only schema.
