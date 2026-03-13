---
name: system-journey-analyst
description: "Expert system analyst — audits codebases to discover gaps, designs solutions, and writes comprehensive Use Cases & Business Journey documents covering SA → DEV → QA pipeline. Combines multi-pass deep analysis with sub-agent team orchestration for brainstorming best approaches. Use this skill when analyzing systems end-to-end, finding bugs/gaps/design issues, writing Use Cases & Business Journeys, producing tech design docs, conducting gap analysis, creating QA test matrices, or when the user asks to review a feature's completeness, write journey docs, or analyze system behavior — even if they just say 'analyze this feature' or 'write a journey doc'."
argument-hint: "The feature, module, or system area to analyze and document"
metadata:
  author: phumin-k
  version: "1.1"
  scope: "**"
  tier: T1
  triggers:
    - "analyze system"
    - "use case"
    - "journey"
    - "gap analysis"
    - "end-to-end audit"
---

# System Journey Analyst

## When to use this skill

- Analyze a feature/module/system end-to-end: find gaps, bugs, race conditions, data integrity issues
- Write Use Cases & Business Journey documents from code analysis
- Produce tech design documentation for SA → DEV → QA pipeline
- Gap analysis with severity assessment and priority matrix
- Design recommendations with concrete code solutions
- Generate QA test scenario matrices from journey analysis

## Philosophy

**Code is the source of truth — not assumptions, not specs, not wikis.**

Read all relevant code first. Trace every path. Verify every finding against actual source lines. Gaps that can't be demonstrated with a code reference or reproducible scenario are not gaps — they're speculation.

Produce documents that **3 audiences can act on immediately**:
- **SA** — understands the complete business flow, gaps, and design recommendations
- **DEV** — gets exact code locations, fix patterns, and implementation specifications
- **QA** — gets a test matrix with scenarios, inputs, expected results, and priority

### Hard Rules

1. **Every finding MUST cite file + line** — no vague "this might have issues"
2. **Every gap MUST have a severity** — HIGH / MEDIUM / LOW with concrete risk description
3. **Every recommendation MUST include code** — minimal targeted diff, not full rewrites
4. **Verify before reporting** — re-read the actual code to confirm the issue exists (Pass 5)
5. **Accepted-by-design is valid** — not every gap needs fixing; document trade-off rationale
6. **No hallucinated scenarios** — only report journeys that the code actually supports or should support

---

## Analysis Workflow

### Phase 0: Scope & Discovery

**Goal:** Understand what we're analyzing before diving in.

1. **Read manifest/README** — project structure, build system, dependencies
2. **Identify entry points** — how is the feature invoked? (API, batch job, event, scheduler)
3. **Map the call chain** — entry → service → repository → external systems
4. **List all files in scope** — use Explore sub-agent for ≥3 unknown files

**Discovery Checklist:**
```
□ Entry point identified (controller/executor/listener)
□ Service classes mapped
□ Data access layer identified (repositories/JdbcTemplate/DAOs)
□ External integrations found (REST, file I/O, messaging)
□ Configuration/properties identified
□ Database tables and schemas listed
□ Error handling strategy understood (exceptions, retries, fallbacks)
```

**Sub-agent delegation:**
- ≥3 files to read → Explore agent: `TASK: Map call chain for {feature}. SCOPE: {directory}. CONTEXT: {what we know}. RETURN: Ordered list of classes with responsibilities + key method signatures + file paths. DEPTH: medium`

### Phase 1: Deep Code Audit

**Goal:** Understand every code path — happy path, error paths, edge cases, concurrency.

**For each class in the call chain, extract:**

| Aspect | What to capture |
|--------|----------------|
| **Input validation** | What's validated? What's NOT validated? |
| **State transitions** | What status/state changes? What triggers them? |
| **Transaction boundaries** | Where do commits/rollbacks happen? |
| **Error handling** | Catch blocks, retry logic, fallback behavior |
| **Concurrency** | Shared state, thread safety, race conditions |
| **External I/O** | File reads/writes, API calls, DB queries |
| **Idempotency** | Can this be re-run safely? What happens on retry? |
| **Data flow** | Input → transform → output for each operation |

**Trace every branch:**
- Happy path (all inputs valid, all operations succeed)
- Partial failure (some records fail, others succeed)
- Complete failure (exception at each possible point)
- Kill/crash recovery (what state is left? can it resume?)
- Concurrent execution (what if 2 instances run simultaneously?)
- Edge cases (empty input, max size, boundary values, encoding)

### Phase 2: Gap Detection

**Goal:** Find everything that could go wrong, is missing, or is suboptimal.

**Gap Categories:**

| Category | What to look for |
|----------|-----------------|
| **Data Integrity** | Partial writes, crash between file+DB update, missing atomic operations |
| **Error Handling** | Uncaught exceptions, empty catch blocks, generic error messages |
| **Idempotency** | Re-run produces different results, duplicate processing |
| **Concurrency** | Race conditions, shared mutable state, lock ordering |
| **Input Validation** | Missing validation at system boundary, encoding, format, size |
| **Privacy/Security** | PII in logs, missing masking, hardcoded secrets |
| **Reliability** | Single point of failure, no timeout, stuck state, no monitoring |
| **Operations** | No housekeeping, unbounded growth, missing metrics, vague logs |
| **Configuration** | Hardcoded values that should be configurable |
| **Correctness** | Off-by-one, wrong boolean logic, subtle counting bugs |

**Gap Severity Definitions:**

| Severity | Criteria |
|----------|----------|
| **HIGH** | Data corruption, security vulnerability, job stuck permanently, incorrect business output |
| **MEDIUM** | Silent data loss, operational burden, degraded reliability, missing validation |
| **LOW** | Cosmetic, minor hardcoding, observability improvements, nice-to-have |

**Gap Documentation Format:**
```markdown
| ID | Severity | Description | Category |
|---|---|---|---|
| GAP-{NN} | HIGH/MEDIUM/LOW | {What's wrong} — {concrete risk} | {Category} |
```

### Phase 3: Solution Design

**Goal:** Design fixes for every gap, prioritized by risk × effort.

**For each gap, produce:**

1. **Root cause** — why does this gap exist?
2. **Impact** — what happens if not fixed? (concrete scenario)
3. **Fix approach** — how to fix it (1-2 sentences)
4. **Code diff** — minimal targeted code change (±5 lines context)
5. **Effort** — S (< 1 day), M (1-3 days), L (3+ days)
6. **Dependencies** — does this fix require other fixes first?

**Priority Matrix Template:**
```markdown
### P0: Must Fix Before Production
| GAP | Risk | Effort | Fix |
|-----|------|--------|-----|

### P1: Should Fix (Production Hardening)
| GAP | Risk | Effort | Fix |
|-----|------|--------|-----|

### P2: Operational Excellence
| GAP | Risk | Effort | Fix |
|-----|------|--------|-----|

### Accepted by Design
| GAP | Risk | Rationale |
|-----|------|-----------|
```

**Design Recommendation Format (REC-{NN}):**
```markdown
### REC-{NN}: {Title} ({GAP-ID} fix)

**Problem:** {1-line description}
**Root cause:** {why this happens — cite file:line}
**Fix:** {approach}

Before:
​```java
// current code
​```

After:
​```java
// fixed code
​```

**Testing:** {how to verify this fix}
**Blast radius:** {what else is affected}
```

### Phase 4: Use Cases & Business Journey Writing

**Goal:** Produce comprehensive documentation that SA, DEV, and QA can act on.

#### Document Structure (13 sections)

| # | Section | Audience | Purpose |
|---|---------|----------|---------|
| 1 | **Overview** | All | What the feature does, entry points, file specs |
| 2 | **Tables Affected** | DEV, QA | All database tables with columns and purpose |
| 3 | **Configuration Properties** | DEV, Ops | All configurable properties with defaults |
| 4 | **Status Lifecycle** | All | State machine diagram (Mermaid) + transition rules |
| 5-9 | **Business Journeys** | SA, DEV | Use cases grouped by: Success → Exception per phase → Cross-cutting |
| 10 | **Gap Analysis** | SA, DEV | Fixed gaps + Open gaps with severity |
| 11 | **Priority Matrix** | SA, PM | P0/P1/P2/Accepted categorization |
| 12 | **Design Recommendations** | DEV | Concrete fixes with before/after code |
| 13 | **Test Scenarios** | QA | Full test matrix with inputs + expected outputs |

#### Use Case Template

```markdown
### UC-{NN}: {Title}

**Trigger:** {What initiates this journey}
**Precondition:** {System state before}
**Postcondition:** {System state after}

**Journey:**

​```
Step 1 → {action} → {result}
Step 2 → {action} → {result}
...
​```

**Key Code Path:**
- `{Class}#{method}` (L{line}) — {what it does}
- `{Class}#{method}` (L{line}) — {what it does}

**Database Changes:**
| Table | Operation | Condition |
|-------|-----------|-----------|
| {table} | INSERT/UPDATE/DELETE | {when} |

**Verification:** {How QA can verify this journey}
```

#### Journey Grouping Strategy

1. **Success Paths** — normal operations that complete without errors
2. **Exception per Phase** — what goes wrong at each processing phase
3. **Cross-Cutting Edge Cases** — scenarios that span multiple phases (resume, idempotency, concurrency)

**Use Case Numbering:**
- UC-01~UC-04: Success paths
- UC-05~UC-08: Phase 1 exceptions
- UC-09~UC-12: Phase 2 exceptions
- UC-13~UC-16: Phase 3 exceptions
- UC-17~UC-22+: Cross-cutting edge cases

#### Test Scenario Template

```markdown
| # | Scenario | Input | Expected | Priority |
|---|----------|-------|----------|----------|
| T-{NN} | {What to test} | {Setup/input data} | {Expected outcome} | Critical/High/Medium/Low |
```

**Priority Rules:**
- **Critical** — happy path, data integrity, crash recovery, idempotency
- **High** — error handling, validation, re-run behavior
- **Medium** — edge cases, performance, encoding
- **Low** — cosmetic, minor operational

### Phase 5: Verification (CRITICAL — do not skip)

For EVERY finding and EVERY use case:

1. **Re-read actual code** — confirm the behavior described is real
2. **Check edge handling** — maybe surrounding code already handles it
3. **Cross-reference** — does another use case contradict this one?
4. **Test coverage** — does the test matrix cover every journey?
5. **Gap completeness** — does every open gap have a recommendation?
6. **If uncertain → demote or drop** — zero false positives > catching everything

---

## Sub-Agent Orchestration

### When to use sub-agents

| Situation | Agent | Task |
|-----------|-------|------|
| ≥3 files to understand | **Explore** | Map call chain, list responsibilities |
| ≥3 files to edit | **Implement** | Apply fix with spec from Phase 3 |
| Verify findings | **Review** | Read-only pass over findings against code |
| Save progress | **MemoryManager** | Record discoveries to session memory |

### Team Brainstorming Pattern

For complex design decisions, use parallel sub-agent exploration:

```
Main Agent:
  1. Define the problem clearly (gap + constraints)
  2. Launch Explore agents in parallel for different approaches:
     - Explore A: "How does {similar_system} handle this?"
     - Explore B: "What patterns exist in codebase for {similar_problem}?"
  3. Synthesize findings → propose 2-3 options with trade-offs
  4. Select best option based on: simplicity, consistency with codebase, effort
```

### Sub-Agent Prompt Template

Every delegation MUST include 5 fields:
```
TASK: {What to do}
SCOPE: {Exact file paths or directories}
CONTEXT: {What we already know — gap ID, phase, relevant code}
RETURN: {Exact format of response expected}
DEPTH: {quick | medium | thorough}
```

---

## Output Deliverables

### For SA (System Analyst)
- Complete Use Cases & Business Journeys
- Gap Analysis with severity and priority
- Priority Matrix (P0/P1/P2/Accepted)
- Status lifecycle diagram

### For DEV (Developer)
- Design Recommendations with before/after code diffs
- Exact file paths and line numbers for every finding
- Database table changes per use case
- Configuration properties reference

### For QA (Quality Assurance)
- Test Scenario Matrix with inputs and expected outputs
- Priority-tagged scenarios (Critical → Low)
- Phase-grouped test organization
- Cross-cutting edge case scenarios

---

## Quality Checklist (before delivering)

```
□ Every gap cites file + line number
□ Every gap has severity (HIGH/MEDIUM/LOW)
□ Every open gap has a design recommendation (REC-{NN})
□ Every recommendation has before/after code
□ Priority matrix covers all open gaps
□ Use cases cover: happy path + exception per phase + cross-cutting
□ Test matrix has ≥1 scenario per use case
□ Status lifecycle diagram matches actual code behavior
□ All findings verified against code (Phase 5 done)
□ No hallucinated scenarios — every journey traceable to code
□ Document version and date in header
□ Audience tag: SA → DEV → QA
```
