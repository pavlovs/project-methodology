# /audit-security

You are performing a **systematic security audit**. Follow this protocol exactly. Do not skip categories.

## Context (pre-computed at invocation)

```
Branch:       $(git branch --show-current 2>/dev/null || echo "unknown")
Changed files: $(git diff --name-only HEAD 2>/dev/null | head -20 || echo "none")
Staged files: $(git diff --name-only --cached 2>/dev/null | head -20 || echo "none")
Stack hint:   $(ls *.py requirements*.txt package.json go.mod Cargo.toml 2>/dev/null | tr '\n' ' ' || echo "unknown")
```

## Scope

If the user specified files or a directory, audit those. Otherwise:
1. Audit all files changed since the last commit (`git diff HEAD`)
2. If no uncommitted changes exist, audit the full codebase

## Step 1 — Inventory the attack surface

Before checking anything, map:
- All entry points (CLI args, HTTP endpoints, file inputs, env vars, stdin)
- All external calls (APIs, subprocesses, database queries, file writes)
- All trust boundaries (user-controlled input that reaches a sensitive operation)

## Step 2 — Check each OWASP category

Work through each category. For every finding, record: **file:line**, **severity** (Critical/High/Medium/Low), **what it is**, **concrete fix**.

**A1 — Injection**
- SQL: string-concatenated queries, f-strings in SQL, missing parameterization
- Shell: `subprocess` with `shell=True` + user input, `os.system()`, backtick execution
- LDAP, XPath, template injection

**A2 — Broken Authentication**
- Hardcoded credentials, API keys, tokens in source
- Secrets in `.env` files that are not gitignored
- Weak or missing auth on sensitive operations

**A3 — Sensitive Data Exposure**
- PII, credentials, or tokens written to log files
- Unencrypted storage of sensitive fields
- Secrets passed via CLI args (visible in process list)

**A4 — XML/XXE** (if XML parsing is present)
- External entity resolution enabled

**A5 — Broken Access Control**
- Path traversal: user input used to construct file paths without sanitization
- Missing authorization checks before privileged operations

**A6 — Security Misconfiguration**
- Debug mode enabled in non-dev environments
- Overly broad file permissions
- Unused dependencies with known CVEs (check `requirements.txt`, `package.json`)

**A7 — Cross-Site Scripting** (if HTML output is generated)
- Unescaped user input in HTML context

**A8 — Insecure Deserialization**
- `pickle.loads()` / `yaml.load()` on untrusted data
- `eval()` / `exec()` on user-controlled strings

**A9 — Known Vulnerable Components**
- Flag any dependency that looks outdated or has a known CVE history

**A10 — Insufficient Logging**
- Security-relevant events (auth failures, permission errors, unexpected inputs) not logged
- Log injection: user input written to logs unescaped

## Step 3 — Check project-specific risks

Read `ai/ARCHITECTURE.md` and `CLAUDE.md` (if they exist). Check for violations of any security invariants documented there.

## Step 4 — Report

Output a structured report:

```
## Security Audit Report
Date: {today}
Scope: {files audited}

### Findings

| # | Severity | Category | File:Line | Issue | Fix |
|---|----------|----------|-----------|-------|-----|
| 1 | Critical  | ...      | ...       | ...   | ... |

### No issues found in
{categories with clean bill of health}

### Recommended actions
{ordered by severity — what to fix first and why}
```

If no findings: say so explicitly. Do not invent issues.

## Step 5 — Fix (if user confirms)

If the user asks you to fix findings:
- Fix Critical and High severity issues immediately
- For Medium and Low: propose the fix, ask before applying
- After fixing: re-run the relevant check to confirm the issue is resolved
- Add a note to `ai/LEARNINGS.md` for any finding that reveals a systemic pattern
