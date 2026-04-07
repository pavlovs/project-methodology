# /review-methodology

Review and maintain the project-methodology templates based on accumulated feedback and learnings from all projects.

**Source of truth:** `github.com/pavlovs/project-methodology` — all changes go there.

**When to use:** Periodically (monthly or after completing a major project) to incorporate lessons learned into the methodology templates.

## Step 1 — Gather inputs

Read all of these:

1. **Methodology templates** (fetch from GitHub): `curl -sL` each template from `https://raw.githubusercontent.com/pavlovs/project-methodology/main/templates/ai/LEARNINGS.md` (and other template files as needed)
2. **Global feedback**: `CLAUDE_COWORK/Claude_Context/feedback.md` — corrections and behavioral patterns that may indicate methodology gaps
3. **All project learnings**: scan for `CLAUDE_COWORK/*/ai/LEARNINGS.md` — any project with learnings not yet upstreamed
4. **Memory**: check `MEMORY.md` for methodology-related memories

## Step 2 — Diff each project against templates

For each project found with `ai/LEARNINGS.md`:
1. Run the same extraction logic as `/upload-learnings` Step 3 (extract, classify, deduplicate)
2. Also check the project's `CLAUDE.md` for non-negotiable decisions that differ from the template — these may indicate template improvements
3. Check the project's `ai/ARCHITECTURE.md` for invariants worth generalizing

Compile a single consolidated list across all projects.

## Step 3 — Present methodology review

Present a structured review:

```
## Methodology Review — <date>

### Projects scanned
- <project 1> (M1-M5 complete)
- <project 2> (M1-M3 complete)

### New learnings to upstream (not yet in templates)
| # | Learning | Source project(s) | Classification | Target template file |
|---|----------|------------------|----------------|---------------------|

### Template improvement suggestions
| # | Suggestion | Source | Impact |
|---|-----------|--------|--------|

### Contradictions found
| # | Template says | Project(s) did | Resolution needed |
|---|--------------|----------------|-------------------|

### Feedback items that imply methodology changes
| # | Feedback | Implication for methodology |
|---|----------|---------------------------|
```

## Step 4 — Apply approved changes and push to GitHub

After Roman approves specific items:
1. Clone the repo: `git clone https://github.com/pavlovs/project-methodology.git /tmp/project-methodology`
2. Update the relevant template files
3. If a change affects an architectural principle in `/new-project` (the "Architecture principles baked into every project" section), update `commands/new-project.md` too
4. Bump the minor version in CHANGELOG.md (e.g. 3.1.0 -> 3.2.0)
5. Update `~/.claude/.skill-cache/methodology-version` to match
6. Commit and push to `main`
7. Clean up the temp clone
8. Show the diff of what was pushed

## Step 5 — Record the review

Include in the commit message or CHANGELOG entry:
- Projects reviewed
- Learnings upstreamed (count)
- Template files changed
- Deferred items with reasons

## Notes
- This is a curation session — quality over quantity. Not every learning belongs in the template.
- Keep templates generic. Remove project names, specific APIs, domain terms.
- If a learning contradicts an existing template entry: present both, ask Roman to resolve.
- Never auto-apply without approval.
