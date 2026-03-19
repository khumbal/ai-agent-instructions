---
name: "Delegation Protocol"
description: 'Protocol for delegating tasks to sub-agents — includes model tier strategy (T1/T2/T3), context packages, briefing templates, and skill routing. Loaded when planning multi-step work, splitting complex tasks, choosing which skill to use, briefing sub-agents, or routing work by task type.'
---

# Sub-Agent Delegation

## When to Delegate
Delegate when a sub-agent genuinely adds value — parallel workstreams, isolated expertise, or broad exploration where you lack familiarity. Skip delegation for small tasks (≤3 files, <15 lines) and just execute directly.

## Model Tier Strategy

Match model capability to task complexity:

| Tier | Capability | When to Use |
|------|-----------|-------------|
| T1 — Deep Reasoning (Opus) | Cross-cutting (≥3 callers), security/PII, architecture, complex refactoring |
| T2 — Workhorse (Sonnet) | Standard implementation, test writing, doc updates — **default** |
| T3 — Utility (free/fast) | Memory ops, search, boilerplate, formatting |

**Decision tree:**
```
Security/auth/PII paths?           → T1
Reasoning across ≥5 files?         → T1
Clear spec + ≤3 files?             → T2 (default)
Mechanical (search/memory)?        → T3
```

**Agent mapping:**
- T1 → Main agent (keep) or @Review/@JavaReview
- T2 → @Implement
- T3 → @MemoryManager or @Explore

**Rules:**
- Never delegate T1 to T3 — quality will suffer
- Never do T3 on main agent — wastes premium capacity
- Never delegate without Context Package — any tier

## Before Delegating
Ensure you know:
1. **What exactly?** — specific action or answer needed
2. **Where exactly?** — specific files, directories, classes (search first if unknown)
3. **How deep?** — quick / medium / thorough
4. **What tier?** — T1/T2/T3 (determines which agent)

If WHERE is vague → search first. Never delegate without a clear scope.

## Briefing Format
Every sub-agent prompt includes:
```
TASK: [1 action verb + object]
SCOPE: [explicit files/dirs]
CONTEXT: [what, why, what's known — 2-3 sentences]
RETURN: [expected output format]
DEPTH: [quick|medium|thorough]
SKILL: [skill name or "none"]
```

## Context Package (MANDATORY for @Implement / @Review)

Every @Implement or @Review call must include:

```
CONTEXT PACKAGE:
  1. PROJECT STACK: [language, framework, build tool]
  2. AGREEMENTS (coding taste):
     - [pattern to follow — paste 5-10 lines of example code]
     - [naming, error handling, test conventions]
  3. ANTI-PATTERNS:
     - [e.g., "Do NOT use @SpringBootTest"]
  4. PLAN ITEMS:
     - [specific items + ANCHOR strings + expected behavior]
```

Without agreements → wrong assertion style. Without anti-patterns → wrong framework.

### @Implement Briefing Template

```
TASK: Apply [N] code fixes from plan Phase [X]
SCOPE: [exact file paths]

CONTEXT PACKAGE:
  PROJECT: [e.g., Java 11 / Spring Boot 2.2.6 / Maven / Oracle DB]
  AGREEMENTS:
  - [Pattern to follow with 5-10 lines example]
  - Error handling: [describe]
  - Null safety: [describe]
  ANTI-PATTERNS:
  - Do NOT [specific thing]
  PLAN ITEMS:
  [paste FIX items with FIX-ID, FILE, TARGET, CHANGE, ANCHOR]

RETURN: For each file: path + changes + any deviation with reason
DEPTH: thorough
SKILL: java-coding
```

### @Review Briefing Template

```
TASK: Verify [N] fixes from Phase [X] match plan specifications
SCOPE: [modified file paths]

CONTEXT PACKAGE:
  PLAN: [paste plan items with expected behavior]
  AGREEMENTS: [conventions that should have been followed]
  CHECK:
  1. Each fix matches plan spec (correct logic, not just compiles)
  2. New code follows same patterns as existing code
  3. No regressions to callers
  4. Tests actually test the fix
  5. No unused imports or dead code

RETURN: VERDICT (PASS | PASS_WITH_NOTES | FAIL) + findings list
DEPTH: medium
SKILL: code-review
```

## Skill Routing
| Work Type | Sub-Agent | SKILL | Tier |
|-----------|-----------|-------|------|
| Source code (≥4 files) | @Implement | `java-coding` | T2 |
| Source code (≤3 files) | Main agent | `java-coding` | T2 |
| Security/cross-cutting | Main agent | `java-coding` | T1 |
| Unit tests | @Implement or main | `java-unit-test` | T2 |
| Post-impl review | @Review | `code-review` | T1 |
| Deep Java review | @JavaReview | `java-expert-review` | T1 |
| Refactor / optimize | @Implement | `code-improvement` | T2 |
| Architecture / design | Main agent | `smart-design` | T1 |
| Flow diagrams | @Explore or main | `java-flow-extraction` | T2 |
| Tablet WebView | @Implement | `eapp-webview` | T2 |
| Doc updates | Main agent | none | T2 |
| Memory save | @MemoryManager | none | T3 |
| Codebase exploration | @Explore | none | T3 |
| Session/agent review | Main agent | `agent-session-review` | T1 |
| Decision/trade-off reasoning | Main agent | `senior-reasoning` | T1 |
| Simple edit (<15 lines) | Main agent | none | — |

## Depth Guide
| Depth | When | File scope |
|-------|------|-----------|
| quick | Direct answer, surface scan | 1-3 files |
| medium | Trace one flow, key connections | 3-7 files |
| thorough | Full analysis, edge cases | 7+ files |

## Delegation Decision Matrix

```
Scope          | Strategy                 | Tier | Quality Gate
≤3 files       | Main agent + skill       | T2   | QG1 + QG2
4-8 files      | @Implement + full brief  | T2   | QG1 + QG2 + QG3
≥9 files       | 2-3 @Implement by module | T2   | QG1 + QG2 + QG3 per batch
Security/arch  | Main agent (keep)        | T1   | QG1 + QG2 + QG3
Post-impl QA   | @Review / @JavaReview    | T1   | Report → fix if needed
Test only      | Main or @Implement       | T2   | QG2
Doc only       | Main agent               | T2   | Manual verify
Memory save    | @MemoryManager           | T3   | None
Exploration    | @Explore                 | T3   | Summary only
```

## Anti-Patterns

- ❌ "Look at the codebase and understand how X works" → unbounded scope
- ❌ "Find everything related to X" → no scope limit
- ❌ "Implement the changes" without file paths or spec
- ❌ Delegating before locating files → search first
- ❌ Multiple Explores on same scope → combine into ONE
- ❌ Delegating T1 to T3 agent → quality will suffer
- ❌ Doing T3 work on main agent → wastes premium capacity
- ❌ Delegating without Context Package → generic output

## After Delegation
1. Read the response once — extract what you need
2. Insufficient? → follow up with narrower, more specific scope
3. Verify critical findings with one targeted check
4. Sub-agent fails → execute directly (no retry loop)

## Task Decomposition
Multi-layer changes → split into sequential sub-agent calls, one per layer:
DB/Entity → Service/Logic → Controller/UI
