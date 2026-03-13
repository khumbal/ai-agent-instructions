---
name: code-review
description: "Multi-pass code review inspired by Claude Code Review. Catches bugs, security issues, regressions through structured passes with verification. Use for PR review, changed file inspection, pre-merge quality check, or post-implementation review."
argument-hint: "The files or feature to review"
metadata:
  author: phumin-k
  version: "1.1"
  scope: "**"
  tier: T1
  triggers:
    - "review"
    - "PR review"
    - "check quality"
    - "verify changes"
    - "pre-merge"
---

# Code Review

## When to use this skill

Any code review — changed files, PR review, pre-merge inspection, post-implementation quality check.

## Review Philosophy

**Default = correctness.** Find bugs that break production — not formatting or naming opinions.
Expand scope only when RETURN field requests (e.g., "security + correctness", "full review").

## Multi-Pass Analysis

### Pass 1: Correctness & Logic
- Logic errors, off-by-one, null/empty handling, wrong comparisons
- Missing edge cases (empty list, null input, boundary values, concurrent access)
- Type mismatches, wrong return types, unchecked casts
- Resource leaks (unclosed streams, connections, transactions)
- Race conditions in multi-threaded code

### Pass 2: Security (OWASP-aware)
- SQL injection (string concatenation in queries)
- Command injection (Runtime.exec with user input)
- Hardcoded credentials, API keys, secrets
- Missing input validation at system boundaries
- Logging sensitive data (passwords, tokens, PII)

### Pass 3: Integration & Regression
- Does change break existing callers? (check usages via LSP/grep)
- Database changes backward-compatible?
- Transaction boundaries correct? (commit/rollback paths)
- Error handling consistent with existing patterns?
- New code follows same patterns as parallel existing code?

### Pass 4: Verification (reduces false positives)
For each finding from Pass 1-3:
1. Re-read the actual code line to confirm
2. Check if surrounding code already handles the case
3. Check if it's a framework convention (not a bug)
4. If uncertain → demote to 🟢 Nit or drop entirely
**Never report an issue you haven't verified against actual code.**

## Severity Levels

| Icon | Level | Meaning |
|------|-------|---------|
| 🔴 | Critical | Bug that will break production. Must fix. |
| 🟡 | Warning | Should fix — risk of future bugs or mild security concern |
| 🟢 | Nit | Optional improvement |
| 🟣 | Pre-existing | Bug exists but NOT introduced by this change |

## Context Gathering

1. `get_changed_files` tool → see what changed (staged/unstaged)
2. Each changed file: grep modified methods → read ±30 lines context
3. Check callers of modified methods (LSP usages or grep) for regression risk
4. Read `/memories/repo/` for project-specific rules

## Output Format

```
## Review: [feature or file]

### 🔴 Critical
- **[file:L##]** Issue → Fix

### 🟡 Warning
- **[file:L##]** Issue → Fix

### 🟢 Nit
- **[file:L##]** Suggestion

### 🟣 Pre-existing
- **[file:L##]** Issue

### ✅ Build Check: Pass/Fail

### 📊 Summary
- Files: N | Findings: N 🔴  N 🟡  N 🟢
- Verdict: [PASS | PASS WITH WARNINGS | BLOCK]
```

## Rules
- **Zero false positives > catching everything** — only report verified issues
- **Cite file + line** — always with link
- **No style police** — don't flag formatting/naming unless repo rules say to
- **Pre-existing = 🟣** — never block merge for pre-existing issues
