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

## Step 6 — Journey Verification (End-to-End)

After spec-match review passes, verify the **actual runtime journey** works — not just that each piece was built correctly. Components can pass individual review but be disconnected, miswired, or produce dead paths.

### 6a. Trace the entry-to-output path

Starting from the **task entry point** (CLI command, API endpoint, event trigger — whatever initiates the workflow), trace step-by-step:

1. **Entry** — Where does input arrive? Is it parsed/validated correctly?
2. **Routing** — Does input reach the correct handler/processor? Are conditionals wired?
3. **Processing** — Does each processing stage call the next? Are cross-stream contracts actually invoked (not just defined)?
4. **Side effects** — Are DB writes, event emissions, file outputs, API calls actually triggered in the flow?
5. **Output** — Does the final result propagate back to the caller/user?

### 6b. Wiring audit

For each cross-stream boundary from the Work Stream Manifest:
- **Grep the actual call site** — is Stream A's output function actually called by Stream B's consumer? Not just importable, but invoked.
- **Trace data values, not just types** — a `string[]` field in Stream A producing `["internal", "audit"]` won't match Stream B expecting `["user", "admin"]`. Read the producer, verify the consumer matches.
- **Check registration/initialization** — components that require registration (middleware, plugins, event listeners, DI bindings) must have their `register()` / `use()` / `bind()` call present in the startup path.

### 6c. Smoke-test the journey

Run (or construct) a minimal end-to-end scenario:
- If tests exist → execute an integration/e2e test that exercises the full path
- If no e2e test exists → mentally walk through with a concrete example input, verifying each hop produces the expected intermediate state
- Flag any **dead path**: code that exists but is unreachable from the entry point

### 6d. Verdict & Auto-Remediation Loop

Produce a journey verdict table:

| Hop | From → To | Status | Evidence |
|-----|-----------|--------|----------|
| 1 | CLI input → Router | ✅ wired | `cli/index.ts:42` calls `router.dispatch()` |
| 2 | Router → AuthMiddleware | ✅ wired | `router.ts:15` registered in `app.use()` |
| 3 | AuthMiddleware → UserService | ⚠️ partial | `auth.ts:30` imports but never calls `userService.validate()` |
| 4 | UserService → DB | ✅ wired | `user-service.ts:22` calls `repo.save()` |

**If ANY hop is ⚠️ or ❌ → do NOT stop at reporting. Execute the remediation loop:**

#### Remediation Loop (max 3 rounds)

```
round = 0
while broken_hops exist AND round < 3:
  round++

  1. Group broken hops by owning stream (from Work Stream Manifest)

  2. For each affected stream, delegate to @Implement:
     TASK: Fix journey wiring gaps for [stream name]
     SCOPE: [files from the original stream + the cross-stream call site]
     CONTEXT PACKAGE:
       BROKEN HOPS:
       - Hop N: [From] → [To] — [what's wrong: missing call, wrong values, unregistered]
       - Expected: [what the correct wiring should look like]
       - Evidence: [file:line where the gap exists]
       CONTRACTS: [inline the shared interface that should connect these]
       CONSTRAINT: Fix the wiring gap only. Do not refactor unrelated code.
     RETURN: What was wired, file:line of the new/fixed call site, before→after diff summary
     DEPTH: thorough

  3. After each @Implement returns:
     - Run type-check (get_errors) on changed files
     - Run affected tests
     - Re-trace the specific broken hops to verify they are now ✅

  4. Update the verdict table with new status
```

If after 3 rounds broken hops remain → **stop and escalate to user** with:
- Which hops are still broken and why
- What was attempted
- Suspected root cause (likely architectural mismatch requiring design change)

**Only declare "complete" when every hop in the journey is ✅ wired. No exceptions.**

## Guard Rails

- **No file overlap** — same file must not be read-write in 2+ streams
- **Contracts first** — write shared interfaces before any @Implement delegation
- **Context Package mandatory** — every @Implement call includes project stack, agreements, anti-patterns, and inline contract code
- **Verify after each stream** — don't batch all verification to the end
- **No blind merge** — type-check + tests must pass before declaring complete
- **Wired, not just built** — every component must be reachable from the entry point. Orphaned code = incomplete delivery.

## Output

When complete, summarize to the user:
- What was built (per stream, 1-2 lines each)
- Key design decisions made
- Test results (pass/fail count)
- Journey verdict table (all hops ✅)
- Any remaining risks or TODOs
