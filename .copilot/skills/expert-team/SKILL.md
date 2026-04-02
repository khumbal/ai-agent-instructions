---
name: expert-team
description: "Orchestrate a team of specialized agents for large multi-file tasks. Breaks work into isolated streams with explicit contracts, delegates to @Explore/@Implement/@Review, and verifies integration. Use when implementation spans 5+ files across multiple modules, or when user says 'สร้างทีม Expert Agent', 'Agent แบ่งงาน', 'จัดสรรงานให้ sub-agent'."
argument-hint: "The task description and scope"
metadata:
  author: phumin-k
  version: "2.0"
  scope: "**"
  tier: T1
  triggers:
    - "expert team"
    - "large implementation"
    - "multi-module"
    - "team protocol"
    - "orchestrate"
    - "สร้างทีม"
    - "Agent แบ่งงาน"
    - "จัดสรรงาน"
    - "sub-agent"
---

# Expert Agent Team — Orchestrated Multi-Stream Implementation

## When to use this skill

- Task spans 5+ files across multiple modules
- Work can be decomposed into independent streams with clear boundaries
- Benefits from structured contract-first approach

**Don't use when:** Fewer than 5 files or single module → just do it directly or use `plan-to-implementation`.

## Philosophy

> **You are the orchestrator.** You reason about architecture, write shared contracts, delegate implementation to @Implement agents, and verify quality via @Review.
> Every stream gets an explicit scope — no file appears in two streams.
> Every delegation includes a full Context Package (see delegation-protocol).

---

## Step 1 — Gather Context & Assess Scope

1. Read project conventions (README, package.json, build configs, `/memories/repo/`)
2. Delegate to **@Explore** (thorough) to map the affected codebase area:

```
TASK: Map all files and modules affected by [task]
SCOPE: [relevant source directories]
CONTEXT: [what the task is, what areas likely touched]
RETURN: List of affected files grouped by module, existing patterns/types, dependencies between modules
DEPTH: thorough
```

3. **Scope gate:** If Explore returns fewer than 5 affected files → tell the user this doesn't need a full team. Switch to direct implementation or `plan-to-implementation` skill.

## Step 2 — Architect (You)

You design the architecture directly — don't delegate this. You have the full context.

### 2a. Analyze

From the Explore results, identify:
- Existing types, interfaces, and patterns to reuse
- Cross-module dependencies and shared contracts
- Natural stream boundaries (files that change together vs independently)

### 2b. Design shared contracts

Design shared interfaces/schemas that multiple streams depend on. Write them to the codebase **before** delegating any implementation — this ensures all @Implement agents can reference real code.

### 2c. Produce Work Stream Manifest

Create a markdown table:

| Stream | Files (read-write) | Read-only deps | Agent | Skill | Acceptance criteria |
|--------|-------------------|----------------|-------|-------|-------------------|
| Auth middleware | `src/middleware/auth.ts` | `src/types/user.ts` | @Implement | vinyan-coding | Token validation works, tests pass |
| User service | `src/services/user.ts`, `src/repo/user.ts` | `src/types/user.ts` | @Implement | java-coding | CRUD operations, 3 unit tests |

**Rules:**
- No file appears as read-write in more than one stream
- Every stream has explicit acceptance criteria
- Assign the appropriate skill per stream's domain
- Cross-stream dependencies must go through contracts written in 2b

## Step 3 — Implement (per stream)

For each stream, delegate to **@Implement** sequentially. Each delegation includes a full Context Package:

```
TASK: Implement [stream name] from Work Stream Manifest
SCOPE: [exclusive file paths for this stream]

CONTEXT PACKAGE:
  PROJECT: [language, framework, build tool]
  AGREEMENTS:
  - [Pattern to follow — paste 5-10 lines of example code from existing codebase]
  - [Naming, error handling, test conventions]
  ANTI-PATTERNS:
  - [What NOT to do in this project]
  CONTRACTS:
  - [Inline the shared interface/schema code from Step 2b — not just file references]
  PLAN ITEMS:
  - [Specific changes with ANCHOR strings for each file]

RETURN: Files changed + change summary, decisions + rationale, acceptance criteria checklist (pass/fail)
DEPTH: thorough
SKILL: [matched skill from manifest]
```

**Each @Implement agent also writes tests for their stream.**

### After each stream completes:
- Verify the returned acceptance criteria
- Run type-check on the changed files (`get_errors`)
- If a stream fails → fix with a targeted follow-up @Implement on that stream only. Don't restart the pipeline.

## Step 4 — Integrate

After all streams complete:

1. Run full type-check across all changed files
2. Run the project's test suite
3. Check for import conflicts or interface mismatches between streams
4. If integration fails → diagnose root cause, fix directly (small fix) or delegate targeted @Implement (larger fix)

## Step 5 — Review

Delegate to **@Review** for cross-stream quality check:

```
TASK: Review cross-stream consistency and integration quality
SCOPE: [all files changed across all streams]
CONTEXT: [what was built, the shared contracts, acceptance criteria]
RETURN: Issues found with severity (critical/warning/nit), specific file:line references
DEPTH: thorough
SKILL: code-review
```

If critical issues found → fix with targeted @Implement on affected stream, re-run affected tests only.

## Guard Rails

- **No file overlap** — same file must not be read-write in 2+ streams
- **Contracts first** — write shared interfaces before any @Implement delegation
- **Context Package mandatory** — every @Implement call includes project stack, agreements, anti-patterns, and inline contract code
- **Verify after each stream** — don't batch all verification to the end
- **No blind merge** — type-check + tests must pass before declaring complete

## Output

When complete, summarize to the user:
- What was built (per stream, 1-2 lines each)
- Key design decisions made
- Test results (pass/fail count)
- Any remaining risks or TODOs
