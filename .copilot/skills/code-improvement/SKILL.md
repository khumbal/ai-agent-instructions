---
name: code-improvement
description: Analyzes, improves, and refactors existing code — from single-file optimization to multi-file restructuring. Applies SOLID principles, design patterns, performance tuning, and phased refactoring workflows while preserving functionality. Prevents duplicate files and enforces reuse-first approach. Use this skill whenever the user asks to refactor, optimize, improve, clean up, restructure modules, consolidate duplicates, reorganize files, reduce technical debt, apply design patterns, simplify, or enhance code quality, performance, maintainability, or scalability — even if they don't explicitly say "improve".
argument-hint: "The file, module, or area to improve"
metadata:
  author: phumin-k
  version: "3.1"
  scope: "**"
  tier: T2
  triggers:
    - "refactor"
    - "optimize"
    - "clean up"
    - "DRY"
    - "restructure"
    - "consolidate"
    - "reduce technical debt"
---

# Code Improvement & Refactoring

## When to use this skill

Use when refactoring, optimizing, cleaning up, restructuring, consolidating duplicates, reducing technical debt, or improving code quality at any scale.

## Conditional workflow

1. Determine the task scope:

   **Single file?** → Follow "Single File Workflow" below
   **Multiple files?** → Follow "Multi-File Restructure" below
   **Performance issue?** → Benchmark FIRST, change, benchmark AGAIN
   **Pattern consolidation?** → Search ALL occurrences first, plan batch changes

## Hard rules

- **Feature preservation is non-negotiable** — maintain behavior, backward compatibility, public APIs unless explicitly approved
- **Reuse first** — search workspace and edit existing files before creating new ones
- **One file per concept** — never create `rate_limit.go` when `ratelimit.go` exists
- **No partial fixes** — change ALL occurrences or none

## Pre-work (do this first)

1. Read target code + surrounding context (imports, callers, tests)
2. `file_search` and `grep_search` for existing patterns — don't reinvent
3. Map impact scope: what depends on this code?
4. Verify business requirements before changing anything

## Single file workflow

```
Analyze → Plan → Implement → Validate
                      ↑           ↓
                      └── Fix ← Failed?
```

1. Read code, identify issues, prioritize by impact vs effort
2. Plan changes with rationale, assess what could break
3. Apply changes incrementally
4. **Validate** — run type checker / linter / tests after each step
5. If validation fails → fix issue → validate again (loop until green)

## Multi-file restructure

Copy this checklist and track progress:

```
Progress:
- [ ] Phase 0: Discovery — file inventory + import mapping
- [ ] Phase 1: Analysis — find duplicates, check usage
- [ ] Phase 2: Implement — reuse first, extend existing, validate each change
- [ ] Phase 3: Cleanup — remove unused, merge similar files
- [ ] Phase 4: Final validation
```

**Phase 0: Discovery (do not skip)**
1. Create file inventory (list all files involved)
2. Map import/export dependencies
3. Plan phases with validation criteria for each

**Phase 2: Implement** — Validate after each change:
- Build passes? → Continue. Fails? → Fix before moving on.
- No broken imports? → Continue. Broken? → Fix immediately.

**Phase 4: Final validation**
```
- [ ] Build succeeds
- [ ] All relevant tests pass
- [ ] No duplicate files (file_search confirms)
- [ ] Import integrity (no broken references)
- [ ] File count justified (audit before/after)
```

## Anti-patterns (from real failures)

- Creating duplicate files without searching first
- Skipping pre-analysis → broken imports, orphaned files
- Partial fixes → inconsistency across codebase
- Big-bang rewrites → prefer incremental refactoring
- Premature optimization → profile first, optimize second
- Commented-out code → delete it (Git preserves history)
- Multiple implementations for same feature (e.g., 2 wizard flows)
- "Two ways to do same thing" without clear reason → pick one, delete other

## Pattern consolidation

- When 2+ patterns exist for same task → choose best, delete others
- Evaluate: performance, maintainability, team familiarity, future flexibility
- Has commented code been unused >1 sprint? → Delete
- Git history preserves code → safe to delete

## Production standards (applied during improvement)

- Error handling: structured logging with context + safe fallbacks
- Performance: memoization/caching, lazy loading, efficient data structures
- Architecture: separation of concerns, single responsibility, design for testability

## Recovery protocol

When something breaks: Stop → analyze root cause → rollback if needed → adjust approach → retry.

## Output

After completing work, report:
- What changed and why (rationale, not just description)
- Key decisions and trade-offs
- Measurable improvements (files before/after, lines reduced, complexity lowered)
- Validation status: build ✓ / tests ✓ / imports ✓
