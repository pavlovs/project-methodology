# /upload-learnings

Extract learnings from a project, present for review, and push approved items to the project-methodology GitHub repo.

**Source of truth:** `github.com/pavlovs/project-methodology` — all changes go there.

**Flow:** Project `ai/LEARNINGS.md` -> diff against GitHub template -> present for curation -> approved items committed and pushed to GitHub

## Step 1 — Identify the project

The argument should be a project name or path. Resolve it:
- If a name: look for `CLAUDE_COWORK/<name>/ai/LEARNINGS.md`
- If a path: look for `<path>/ai/LEARNINGS.md`

If the file doesn't exist, stop and say so.

## Step 2 — Read both files

Read:
1. **Project learnings**: `<project>/ai/LEARNINGS.md`
2. **Methodology template** (fetch from GitHub): `curl -sL https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/LEARNINGS.md`

## Step 3 — Extract and classify

Parse each learning (bullet point) from the project file. For each learning:

1. **Check if it already exists** in the methodology template (same concept, even if different wording). Skip duplicates.
2. **Classify** as one of:
   - **Universal** — applies to any project built with this methodology (e.g. "commit immediately after meaningful changes", "stdin for AI prompts not CLI args")
   - **Stack-specific** — applies to projects using a specific stack (e.g. "cp1252 terminal encoding on Windows", "Claude CLI uses `claude.cmd` on Windows")
   - **Project-specific** — only relevant to this project (e.g. "this API returns 429 after 50 calls"). These do NOT go into the template.

## Step 4 — Present for review

Present the learnings in a structured table:

```
## New learnings from <project name>

### Universal (recommend adding to template)
| # | Learning | Section | Already in template? |
|---|----------|---------|---------------------|
| 1 | "Never modify the target codebase — read-only access" | Code scanning | No |
| 2 | ... | ... | ... |

### Stack-specific (recommend adding with context)
| # | Learning | Stack/Platform | Section |
|---|----------|---------------|---------|
| 1 | "Use pathlib.Path everywhere, never hardcode separators" | Windows/cross-platform | Windows specifics |

### Project-specific (stay in project, skip)
| # | Learning | Why project-specific |
|---|----------|---------------------|
| 1 | "Rules are Markdown files, not database rows" | DSGVO-Agent architecture decision |
```

Ask: "Which items should I add to the methodology template? Give me the numbers, or say 'all universal' / 'all recommended'."

## Step 5 — Write approved learnings and push to GitHub

1. Clone the repo to a temp directory: `git clone https://github.com/pavlovs/project-methodology.git /tmp/project-methodology`
2. For each approved learning:
   - Find the right section in `templates/ai/LEARNINGS.md` (Engineering discipline, Data architecture, API and external services, Testing, Windows/platform specifics — or create a new section if none fits)
   - Append the learning as a bullet point
   - Generalize the wording if it was project-specific in phrasing (e.g. "DSGVO-Agent rules" -> "reference data that needs human review")
3. Bump the patch version in CHANGELOG.md (e.g. 3.1.0 -> 3.1.1)
4. Update `~/.claude/.skill-cache/methodology-version` to match
5. Commit and push to `main`
6. Clean up the temp clone
7. Show the diff of what was pushed

## Step 6 — Also check for feedback that improves other templates

Scan the project's files for patterns that suggest template improvements:
- `CLAUDE.md` — did the project add non-negotiable decisions not in the template? Flag them.
- `ai/ARCHITECTURE.md` — did the project establish invariants worth generalizing?
- `ai/DESIGN.md` — did the project develop a classification or scoring system worth templating?

Present these as **methodology improvement suggestions** (separate from learnings). Do not auto-apply — just list them for the next `/review-methodology` session.

## Notes
- Never auto-apply without Roman's approval
- Keep the methodology template generic — no project names, no specific APIs, no domain terms
- If a learning contradicts an existing template entry: flag the conflict, don't silently override
