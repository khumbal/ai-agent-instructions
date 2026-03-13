---
name: plan-to-implementation
description: "Executes a pre-approved fix plan with maximum efficiency — validates plan quality, batches reads/edits by phase, and runs verification. Turns structured plans (GAP→file→line→test) into production code changes in minimal token cost. Use this skill when the user says 'start implementation', 'implement the plan', 'execute fixes', 'apply the changes', or references a saved plan — even if they just say 'go' or 'do it'."
argument-hint: "The plan location (session memory path, or 'last plan') and optional phase filter (e.g. 'P0 only')"
metadata:
  author: phumin-k
  version: "3.0"
  scope: "**"
  tier: T1
  triggers:
    - "implement plan"
    - "execute fixes"
    - "apply changes"
    - "start implementation"
    - "do it"
---

# Plan-to-Implementation — Orchestrated Execution Engine

## When to use this skill

- User says "Start implementation", "implement the plan", "execute fixes", "apply changes"
- A structured plan exists (in session memory, previous turn, or conversation summary)
- Multiple code changes need to be applied from a pre-approved plan

## Philosophy

> **Main agent = orchestrator that executes trivial work directly and delegates complex work with full context.**
> For ≤3 files: main agent writes code itself with skill guidance.
> For 4+ files: main agent assigns work to the right specialist sub-agent and verifies quality at every gate.

> **Implementation turns are pure execution — zero re-analysis.**
> If the plan is good, orchestrate it. If the plan is bad, fix the plan first.

Two failure modes to avoid:
1. **Flat execution** — agent does everything itself without delegation or quality checks → misses edge cases, inconsistent style, no verification
2. **Blind delegation** — agent delegates without context/skill/taste → sub-agent produces generic code that doesn't fit the project

---

## Plan Quality Gate (MANDATORY — do this first)

Before writing any code, validate the plan has these 5 required fields per fix item:

```
✅ GOOD PLAN (executable):
┌─────────────────────────────────────────────────────────────┐
│ FIX-ID:   FIX-5                                             │
│ GAP:      Import glob match inconsistent with archive       │
│ FILE:     src/.../PdpcPurgeExecutor.java                    │
│ TARGET:   L144-162 (executeImport method)                   │
│ CHANGE:   Replace glob filter+sort with exact name.equals() │
│ ANCHOR:   "isInputFile(name)" → "name.equals(expectedName)" │
│ TEST:     Extend SyncPurgeListServiceTest — add 3 methods   │
│ DOC:      pdpc-purge-journey.md §10 Fixed table             │
│ VERIFY:   exact filename picked; no match → return 0        │
└─────────────────────────────────────────────────────────────┘

❌ BAD PLAN (needs enrichment first):
┌─────────────────────────────────────────────────────────────┐
│ "Fix the import file matching to be more consistent"        │
│  → No file path, no line numbers, no anchor string          │
│  → STOP: enrich plan before implementing                    │
└─────────────────────────────────────────────────────────────┘
```

### Required fields checklist

| Field | Purpose | Example |
|-------|---------|---------|
| **FIX-ID** | Tracking reference | FIX-1, FIX-2, GAP-11 |
| **FILE** | Exact relative path | `src/main/java/.../Service.java` |
| **TARGET** | Line range or method name | L393-401, `doExecutePurge()` |
| **CHANGE** | What to do (specific) | "Add PARTIAL branch when failedCount > 0" |
| **ANCHOR** | Code string to search for | `"if (accounts.isEmpty())"` |
| **TEST** | Which test file + what to add | "SyncPurgeListServiceTest — 3 methods for countFailedRecords" |

### Optional but valuable fields

| Field | Purpose | When needed |
|-------|---------|-------------|
| **DOC** | Doc file + section to update | When journey/design docs exist |
| **VERIFY** | Manual verification criteria | When automated tests aren't sufficient |
| **PREREQ** | Dependencies between fixes | When fix order matters |
| **ANCHOR_AFTER** | Code string after the target | When ANCHOR alone is ambiguous |

### If plan is incomplete

```
Plan missing fields? → DO NOT IMPLEMENT YET
  Option A: Enrich plan yourself (grep for anchors, find line numbers)
  Option B: Ask user to clarify scope
  
Time to enrich ≈ 2-3 greps. Time to fix wrong implementation ≈ 10x more.
```

---

## Adaptive Approach Discovery (MANDATORY — before execution)

> **Invoke the `adaptive-discovery` skill before starting execution.**
> It produces an Execution Approach paragraph (APPROACH + STYLE REFERENCE + KNOWN PITFALLS)
> that feeds into Step 0.5 Skill Matrix, Context Package, and @Implement briefs.
>
> Budget: ≤3 tool calls. If nothing found → proceed with engineering judgment.

---

## Execution Workflow

### Overview — Orchestrated Pipeline

```
Load Plan → Validate → Discover Approach → Analyze Skills → Execute → Quality Gate → Report
               ↓ fail       │                    │              │          ↓ fail
          Enrich Plan   Memory/Code          Skill Matrix  ┌────┴────┐  @Review fix
                        Parallel Grep                      │ Phases: │
                                                           │ 1.Code  │ → QG1: compile check
                                                           │ 2.Test  │ → QG2: tests pass
                                                           │ 3.Doc   │ → QG3: review
                                                           └─────────┘
```

### Step 0: Load & Classify Plan

```
1. Load plan from session memory (or extract from conversation summary)
2. Filter by requested phase (P0 only? all?)
3. Count: N fixes × M files = total scope
4. Classify each fix:
   - Source change (src/main/java/**)
   - Test change (src/test/java/**)
   - Doc change (docs/**)
   - Config change (resources/**)
```

### Step 0.5: Skill Analysis & Execution Strategy (NEW — MANDATORY)

**Fast-path:** ≤2 fixes, ≤2 files, <15 lines total → skip formal Skill Matrix table.
Instead, state inline: `Skill: [X], Executor: main, Agreements: [1 sentence]`. Proceed to Step 1.

**Goal:** For each plan item, determine WHAT skills are needed and HOW to execute.

```
For each FIX item in plan:
  1. What TYPE of code change?
     - Business logic in service → SKILL: java-coding
     - Caller/integration change → SKILL: java-coding
     - New test methods → SKILL: java-unit-test
     - Doc/journey update → SKILL: none (main agent)
     - Refactor/consolidation → SKILL: code-improvement
     
  2. What COMPLEXITY level?
     - Trivial (<15 lines, 1-2 files) → Main agent executes directly
     - Medium (15-80 lines, 2-4 files) → Main agent with skill guidance
     - Complex (>80 lines, 5+ files) → @Implement sub-agent with full brief
     
  3. What AGREEMENTS apply? (collect once, pass to all)
     - Project coding conventions (from copilot-instructions.md)
     - Existing patterns in the codebase (from plan's CONTEXT)
     - Test style (JUnit 4 vs 5, assertion library, naming convention)
     - Doc format (version scheme, table format, section structure)
```

**Output: Skill Matrix (build this before any code)**

```
┌──────────┬────────────┬───────────┬────────────┬───────┬──────────────────┐
│ FIX-ID   │ Skill      │ Executor  │ Complexity │ Tier  │ Agreements       │
├──────────┼────────────┼───────────┼────────────┼───────┼──────────────────┤
│ FIX-5    │ java-coding│ main      │ trivial    │ T2    │ exact match ← archive pattern │
│ FIX-2    │ java-coding│ main      │ trivial    │ T2    │ 3-way branch style from L386  │
│ FIX-1    │ java-coding│ main      │ medium     │ T2    │ countX() ← countStagingRecords pattern │
│ Tests    │ java-unit-test│ main   │ medium     │ T2    │ Mockito+JUnit5, AAA, same mock style │
│ Doc      │ none       │ main      │ medium     │ T2    │ v5.1 bump, pipe-delimited table │
│ Review   │ code-review│ @Review   │ —          │ T1    │ verify fix↔spec + pattern consistency │
│ Memory   │ none       │ @MemMgr   │ trivial    │ T3    │ session save only │
└──────────┴────────────┴───────────┴────────────┴───────┴──────────────────┘

Tier column = Model Tier (see delegation-protocol.instructions.md)
```

**Why this matters:**
- Without skill analysis → code works but doesn't match project taste
- Without agreements → each sub-agent invents its own style
- Without complexity assessment → trivial tasks get over-delegated, complex tasks get under-supported
- Without tier assessment → premium model wasted on boilerplate, or cheap model fails on complex reasoning

### Step 1: Parallel Context Read

**Goal:** Read ALL target code sections in ONE parallel batch.

```
Rules:
- Read line range from plan: TARGET ± 20 lines (context for edit)
- If plan has no line numbers → grep ANCHOR first, then read ±20
- NEVER read full files (>150 lines) — always targeted
- Group independent reads → parallel tool calls
- Test files: grep for insertion point (last test method), read ±10
- ALSO read: 1 example of each AGREEMENT pattern (e.g. existing countX method)

Anti-patterns:
✗ Reading the same file twice in the same turn
✗ Reading a file that was already in the conversation summary
✗ Reading 500 lines when you need 30
✗ Sequential reads when they could be parallel
✗ Skipping agreement pattern reads → sub-agent guesses style
```

**Decision tree for files already in context:**

```
File content in conversation summary?
  ├─ YES + has exact code strings → use directly, skip read
  ├─ YES + summary is high-level only → grep ANCHOR to get current line → read ±20
  └─ NO → read from plan's TARGET range ± 20
```

### Step 2: Source Code Changes (with Skill Guidance)

**Goal:** Apply ALL source code edits with consistent style.

**Execution decision:**
```
Total source files ≤ 3?  → Main agent executes directly
Total source files 4-8?  → @Implement sub-agent (ONE call, full brief)
Total source files ≥ 9?  → Split into 2-3 @Implement calls by module
```

**When main agent executes directly:**
```
- Batch ALL source edits into ONE multi_replace call
- Order: smallest scope first → largest scope
  (method change → caller change → new method addition)
- Each replacement: include 3-5 lines context before/after
- After multi_replace: check for unused imports → clean up in same/next call
- FOLLOW the agreement patterns identified in Step 0.5
```

**When delegating to @Implement:**
```
TASK: Apply [N] source code fixes from approved plan
SCOPE: [list exact file paths]
CONTEXT: |
  Plan items:
  [paste FIX items with ANCHOR strings]
  
  Agreement patterns (MUST follow):
  [paste the existing code pattern each fix should match]
  Example: countFailedRecords() must follow countStagingRecords() pattern:
    - same method signature style (LocalDate param)
    - same jdbc.queryForObject pattern
    - same null-safe return (default 0)
  
  Project conventions:
  - [key rules from copilot-instructions.md relevant to this change]
RETURN: List of files modified + exact changes per file
DEPTH: thorough
SKILL: java-coding
```

### Step 3: Quality Gate 1 — Compile Check

```
After source code changes, BEFORE writing tests:
  1. get_errors on all modified source files
  2. If errors → fix immediately (don't proceed with broken code)
  3. If clean → proceed to tests

Why gate here? Tests written against broken source code = wasted effort.
```

### Step 4: Test Changes (with Skill Guidance)

**Goal:** Add/modify tests that verify the fixes AND match existing test style.

**Before writing ANY test, collect test agreements:**
```
From existing test file, extract:
  - Import style (static imports? which assertion library?)
  - Mock setup style (@Mock fields? inline mock()?)
  - Test naming convention (methodName_scenario_expected? Thai comments?)
  - Assertion style (assertThat vs assertEquals vs verify)
  - Helper methods / shared setup (@BeforeEach patterns)
```

**Execution:**
```
- Prefer extending existing test files over creating new ones
- Group test additions into ONE replace_string_in_file per test file
- New test methods MUST match the style of adjacent existing tests
  (same spacing, same assertion library, same comment style)

When delegating tests to @Implement:
  SKILL: java-unit-test
  Include AGREEMENT section with extracted test patterns
```

### Step 5: Quality Gate 2 — Tests Pass

```
1. Run targeted tests: runTests tool with specific test files
   - Include: directly modified test files + related integration tests
   - NOT full mvn test (too slow, too broad)
   
2. If any test fails:
   - Read failure message
   - Fix test code (not source code — if source is wrong, re-examine the plan)
   - Re-run failed tests only
   
3. All pass → proceed to docs
```

### Step 6: Documentation Changes

**Goal:** Update docs in the SAME turn (never defer).

```
Rules:
- Pre-identify doc sections during plan (or grep now if plan didn't)
- Batch all doc edits into ONE multi_replace call
- Common doc updates:
  · Version header bump  
  · "Fixed / Addressed" table → add rows
  · UC postconditions → update affected scenarios
  · Gap Analysis section → move items from Open to Fixed

Anti-patterns:
✗ Deferring doc updates to "next turn" (forces re-read of everything)
✗ Multiple greps to find doc sections (plan should have pre-identified)
✗ Forgetting to bump version number
```

### Step 7: Quality Gate 3 — Review (for non-trivial changes)

**When to trigger:**
```
Total lines changed > 30?           → @Review
Security-sensitive change?           → @Review  
Cross-cutting change (≥3 callers)?   → @Review
Trivial (< 30 lines, ≤ 2 files)?    → Skip review, proceed to report
```

**@Review brief:**
```
TASK: Verify [N] code fixes match their plan specifications
SCOPE: [list modified files]
CONTEXT: |
  Plan: [paste plan items with expected behavior]
  Agreements:
  - [coding conventions that should have been followed]
  - [pattern consistency requirements]
  
  Check specifically:
  1. Each fix matches its plan spec (not just compiles — correct logic)
  2. New code follows same patterns as existing parallel code
  3. No regressions to callers of modified methods
  4. Tests actually test the fix (not just pass trivially)
RETURN: PASS/FAIL + findings list (severity + file:line + issue)
DEPTH: medium
SKILL: code-review
```

**On review failure:**
```
@Review reports issues → 
  CRITICAL/HIGH? → Fix immediately, re-run tests, re-review
  MEDIUM/LOW? → Log for user, proceed (don't over-iterate)
```

---

## Reliability Enforcement Layer (NEW — mandatory for high-reliability execution)

High reliability does not come from good advice alone. It comes from explicit
entry criteria, stop conditions, and exit criteria that the agent must satisfy.

### Preflight Enforcement (must exist before any edit)

Before Step 1 begins, the agent must be able to state these 4 artifacts inline:

```
1. Approved Plan
  - Fix items are executable (FILE + TARGET + CHANGE + ANCHOR + TEST)

2. Execution Approach (= output of Adaptive Approach Discovery — do NOT produce twice)
  - One short paragraph: chosen pattern, style reference, known pitfalls

3. Skill Matrix
  - Each plan item mapped to skill + executor + tier

4. Agreements Snapshot
  - Coding pattern to mimic
  - Test style to mimic
  - Anti-patterns to avoid
```

**If any artifact is missing:**
```
DO NOT EDIT FILES YET.
Complete the missing artifact first or ask the user for the missing input.
```

### Stop Conditions (must pause execution)

Pause and re-assess if any of these happens during implementation:

```
- Plan anchor not found and no obvious replacement anchor exists
- Target code differs materially from the approved plan
- A supposedly trivial change expands into cross-cutting impact
- Tests fail for reasons unrelated to the planned change
- Review finds a spec mismatch or behavioral regression
- New user edits conflict with the code currently being changed
```

**Required response when a stop condition triggers:**
```
1. Stop the current phase
2. State the mismatch in one sentence
3. Rebuild the affected part of the Execution Approach / Skill Matrix
4. Continue only if the scope is still clear
```

### In-Flight Guardrails

```
- Never proceed to tests with compile/errors unresolved
- Never proceed to docs with failing targeted tests
- Never delegate without Context Package
- Never create a second implementation path when extending an existing pattern would work
- Never mark a fix complete until verification for that fix is visible in tests, review, or explicit manual criteria
```

### Completion Contract (must be true before reporting done)

An implementation turn is only "done" if all applicable items are true:

```
□ Source changes match the approved plan
□ Chosen implementation follows an existing project pattern or justified new pattern
□ Targeted tests pass
□ Imports / dead code cleanup completed
□ Required docs updated in the same turn
□ Review completed for non-trivial changes
□ Any residual risks are explicitly reported to the user
□ New patterns/failures/conventions extracted to memory schema (if any new insight emerged)
```

---

## Todo Strategy

**Max 4 items — one per phase, not per fix:**

```
Good:                           Bad:
☐ Apply source code changes     ☐ FIX-5: Import exact filename
☐ Add/update tests              ☐ FIX-2: No-accounts PARTIAL
☐ Update documentation          ☐ FIX-1: Final verdict staging
☐ Run tests & verify            ☐ Add test for FIX-5
                                ☐ Add test for FIX-2
                                ☐ Add test for FIX-1
                                ☐ Update journey doc
                                ☐ Run tests
(4 items, 4 updates)            (8 items, 16+ updates = token waste)
```

---

## Plan Enrichment (when plan is incomplete)

If the plan lacks line numbers or anchors, enrich it efficiently:

```
Enrichment budget: max 1 parallel grep batch + 1 parallel read batch

1. Grep all ANCHOR strings in parallel:
   grep "isInputFile" → line 144
   grep "accounts.isEmpty()" → line 393  
   grep "getFailCount()" → line 127

2. Read all targets ±20 in parallel:
   read PdpcPurgeExecutor.java L124-167
   read SyncPurgeListService.java L373-415

3. Update plan with actual line numbers
4. Proceed to implementation
```

---

## Lessons Learned

All lessons (L-01 through L-17) have been migrated to `/memories/repo/lessons-learned.md`
for grep-based discovery via Adaptive Approach Discovery.

Entries are tagged by domain: `planning`, `testing`, `context`, `execution`, `delegation`, `discovery`.

---

## Sub-Agent Orchestration

All delegation rules are in `delegation-protocol.instructions.md`:
- Model Tier Strategy (T1/T2/T3) — which model for which task
- Delegation Decision Matrix — scope → strategy → quality gate
- Context Package — mandatory for @Implement / @Review
- Briefing Templates — @Implement and @Review with full format
- Skill Routing Table — work type → sub-agent → SKILL → tier

That instruction auto-loads when planning multi-step work or briefing sub-agents.

---

## Evaluation Rubric (Operational — use before final report)

Score the implementation turn across these 6 dimensions:

| Dimension | Pass Standard | Fail Examples |
|-----------|---------------|---------------|
| **Plan Fidelity** | All implemented changes match approved fix items | Extra behavior added, required fix skipped, wrong target edited |
| **Approach Fit** | Reused proven pattern or justified deviation clearly | Wrote generic code while a parallel project pattern existed |
| **Execution Discipline** | Preflight artifacts existed before edits; stop conditions respected | Edited first, clarified later; ignored scope drift |
| **Verification Quality** | Targeted tests and/or review actually validate the fix | Tests pass trivially, wrong tests run, no review when required |
| **Project Consistency** | Naming, structure, assertions, and error handling match local conventions | Mixed styles, invented test pattern, duplicate implementation path |
| **Closure Quality** | Docs updated, cleanup done, residual risks reported | Missing docs, unused imports, silent caveats |

### Rubric Verdict

```
PASS:
  - No dimension fails
  - Verification Quality passes
  - Plan Fidelity passes

PASS_WITH_NOTES:
  - No critical dimension fails
  - Only minor Closure Quality / low-risk review notes remain

FAIL:
  - Plan Fidelity fails, OR
  - Verification Quality fails, OR
  - A stop condition was ignored, OR
  - Significant residual risk is not communicated
```

### Critical Dimensions

These dimensions are non-negotiable:

```
- Plan Fidelity
- Verification Quality
- Execution Discipline
```

If any critical dimension fails, the turn is not complete.

---

## Quick Reference Card

```
"Start implementation" trigger:

  Phase A — ANALYZE (2-3 tool calls)
  ┌─────────────────────────────────────────────────────┐
  │ 1. Load plan (session memory / summary)             │
  │ 2. Validate: 5 fields per fix? YES→proceed NO→enrich│
  │ 3. Invoke adaptive-discovery skill (≤3 tool calls)  │
  │ 4. Build Skill Matrix (what skill + who executes)   │
  │ 5. Collect Agreements (patterns, conventions, taste)│
  │ 6. Preflight check: 4 artifacts present             │
  └─────────────────────────────────────────────────────┘
  
  Phase B — EXECUTE (3-5 tool calls)
  ┌─────────────────────────────────────────────────────┐
  │ 7. Read ALL targets (1 parallel batch)              │
  │ 8. Edit ALL source code (1 multi_replace or @Impl)  │
  │ 9. QG1: compile check (get_errors)                  │
  │10. Edit ALL tests (1 multi_replace per test file)   │
  │11. QG2: run tests (runTests)                        │
  │12. Edit ALL docs (1 multi_replace)                  │
  └─────────────────────────────────────────────────────┘
  
  Phase C — VERIFY (1-3 tool calls)
  ┌─────────────────────────────────────────────────────┐
  │13. QG3: @Review if >30 lines changed                │
  │14. Apply Evaluation Rubric                          │
  │15. Extract new insights → @MemoryManager (if any)   │
  │16. Report results + residual risks                  │
  └─────────────────────────────────────────────────────┘

Token budget guide:
  3 fixes, 2 source files, 1 test file, 1 doc file
  = Phase A: 2 reads + 1 preflight decision
  = Phase B: 1 multi_replace + 1 get_errors + 1 replace + 1 runTests + 1 multi_replace
  = Phase C: 1 @Review (optional) + rubric + memory extract
  = 8-11 tool calls total
```
