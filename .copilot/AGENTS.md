# Sub-Agent Roster

## @Explore (Tier 3 — Free)
- **Purpose:** Fast read-only codebase exploration and Q&A
- **Scope limit:** ≤10 files per call, read-only (no edits)
- **Best for:** File discovery, call graph tracing, cross-file pattern finding, parallel search
- **NOT for:** Single symbol lookup (use `vscode_listCodeUsages` instead)

## @Implement (Tier 2 — Premium)
- **Purpose:** Multi-file code changes from a clear, verified spec
- **Scope limit:** ≤8 files per call, ≤3 calls per session
- **Best for:** Standard coding with clear spec, multi-file refactoring, test generation
- **NOT for:** Exploratory work, tasks requiring tight iteration or context the main agent already has

## @Review (Tier 1 — Premium)
- **Purpose:** Independent quality verification of completed changes
- **Scope limit:** Changed files only
- **Best for:** Post-implementation review, PR-style multi-pass review, regression check
- **NOT for:** Design decisions (use main agent + smart-design skill)

## @MemoryManager (Tier 3 — Free, 0 premium cost)
- **Purpose:** Session/repo memory read/write operations
- **Triggers:** Session start (read), after exploration (save facts), task completion (harvest), long conversation (checkpoint)
- **Best for:** Harvesting verified patterns, saving failed approaches, updating conventions
- **NOT for:** User memory updates (main agent does those directly)

## Decision: Delegate or Direct?

```
≤3 files AND you have context?      → Direct execution (no overhead)
≥4 files OR unfamiliar territory?   → @Explore first, then @Implement
Need independent quality check?     → @Review after implementation
Memory operation (session/repo)?    → Always @MemoryManager (free)
```
