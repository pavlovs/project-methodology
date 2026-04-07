# Design — {Project Name}

DESIGN.md captures the **product logic** — how the system decides what to do. This is distinct from ARCHITECTURE.md (how it's built) and PLAN.md (the build sequence).

Use this file for:
- Classification logic and scoring rules
- Output schema definitions (column-by-column)
- Filter rules and thresholds
- AI prompt design and reason codes
- Any business logic that isn't obvious from the code

---

## Domain Knowledge

{Populated during project setup from Step 1b answers. Key domain concepts, industry terminology, regulatory requirements, and business rules that are not obvious from reading the code. This section is the bridge between the user's expertise and the system's logic.}

### Glossary

| Term | Definition |
|------|-----------|
| {term} | {definition} |

### Industry standards and constraints

{Regulatory requirements, compliance rules, data format standards, or domain conventions that the system must respect.}

---

## What We Are Looking For

{Define the ideal "hit" for this project. What does a positive result look like?
Be specific: size ranges, sector, ownership type, geography, signals that matter.}

**Not wanted:**
{List explicit exclusion criteria}

---

## Classification System (if applicable)

### Class A — {name}
**Criteria (all required):**
- ...
- **Action**: ...

### Class B — {name}
**Criteria:**
- ...
- **Action**: ...

### Class C — Unclear / Manual Review
**Criteria:**
- Website vague or doesn't load
- Interesting signals but insufficient data
- **Action**: Flag for manual review. Do not auto-export.

### Class D — Clear No-Fit
**Criteria (any one sufficient):**
- ...
- **Action**: Exclude. Log reason. No manual review.

---

## Hard Pre-Qualification Filters

Run BEFORE any expensive API calls. Zero cost.

| Filter | Rule | Source field |
|--------|------|-------------|
| Already processed | `domain in dedup_set` | Dedup reference |
| Too large | `count > max_threshold` | Structured data field |
| Wrong sector | `name contains keyword` | Full name |

---

## AI Classification Prompt Design

### Pre-Filter — Keyword auto-exclude (free, zero AI tokens)

Before any AI call, check scraped text + name for keywords that indicate obvious no-fits.
Only add keywords where false-positive risk is essentially zero.

### Output schema (JSON, max 200 tokens)

```json
{
  "klass": "A|B|C|D",
  "score": 0-100,
  "flag_1": true|false,
  "flag_2": true|false,
  "label_text": "2-4 words describing main signal",
  "reason_code": "one code from list below",
  "reasoning": "max 1 sentence"
}
```

### Reason codes

| Code | When to use |
|------|-------------|
| `Passt` | Fits criteria |
| `Unpassende_Branche` | Wrong sector |
| `Zu_Gross` | Too large |
| `Zu_Klein` | Too small |
| `Unklares_Profil` | Can't determine from available text |

### Token efficiency rules

- Scraped text truncated to 2,000 chars
- 4 few-shot examples per call: 2×best class, 1×mid, 1×worst
- Output capped at 200 tokens (structured JSON only)
- Free keyword pre-filter runs before every AI call

---

## Output Schema

### {Output name} — {n} columns

**Group 1 — Identity ({n} cols)**

| Column | Source field | Notes |
|--------|-------------|-------|
| Domain | `domain` | |
| Source | `source` | |

**Group 2 — {purpose} ({n} cols)**

| Column | Source field | Notes |
|--------|-------------|-------|

---

## Deduplication Logic

{Describe how duplicates are detected and handled.}

- **Domain match**: exact normalized domain (strip protocol, www, trailing slash, lowercase)
- **Name match**: normalize company name (strip legal forms, punctuation) → min 4-char key
- Match = copy existing classification, skip re-processing

---

## Ownership / Qualification Gate (if applicable)

{Describe any hard gates that reclassify records based on non-content signals (ownership, size, geography, etc.)}

| Condition | Action | Reason logged |
|-----------|--------|--------------|
| Corporate entity owns >75% | Reclassify → excluded | "Confirmed subsidiary" |
| Unknown owner, >75% share | Reclassify → review | "Unknown owner, high %" |
