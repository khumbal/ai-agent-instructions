---
name: adaptive-discovery
description: "Discover proven approaches before starting complex work — searches structured memory for verified patterns, failed approaches, and project conventions. Use before multi-step implementation, debugging, refactoring, or work in unfamiliar domains. Invoked by plan-to-implementation; also triggered by 'what approach should I use', 'check memory first', or when facing complex multi-file tasks."
metadata:
  author: phumin-k
  version: "1.1"
  scope: "**"
  tier: T2
  triggers:
    - "check memory first"
    - "proven approach"
    - "before starting complex work"
    - "what approach should I use"
---

# Adaptive Approach Discovery

> **Metacognition: Before executing → pause and identify what type of work you're facing, then find a proven approach from past experience.**

## When to use this skill

- Before implementing a multi-fix plan (invoked by plan-to-implementation Step 3)
- Before starting complex debugging or investigation
- Before refactoring or restructuring code
- When working in an unfamiliar domain or codebase module
- When you suspect "this has been done before" but aren't sure where

## Why this step exists

Building blocks (memory, skills, web search) already exist — but without an explicit step
the agent skips them and jumps straight to editing. Result: generic code that compiles
but doesn't fit the project's approach, ignores lessons already learned, and repeats
mistakes from past sessions.

## Situation Assessment (3 probes)

```
PROBE 1 — Domain & Stack Recognition
  Read the task's file paths and change descriptions.
  Identify:
    - Language / framework / module (Java+Spring? React+TS? Python? SQL migration?)
    - Sub-domain (purge? sync? export? import? safebox? API integration?)
    - Risk profile (PII/security? financial calc? cross-cutting? isolated?)

PROBE 2 — Memory Search (past verified approaches)
  ┌──────────────────────────────────────────────────────────────────┐
  │ Structured search using Memory Schema (3 files):                 │
  │                                                                  │
  │ 1. grep "## {domain}:" in verified-patterns.md                   │
  │    → Reuse pattern directly. Copy PATTERN + SOURCE into approach.│
  │                                                                  │
  │ 2. grep "## {domain}:" in failed-approaches.md                   │
  │    → Read LESSON → add to ANTI-PATTERNS in Context Package.      │
  │                                                                  │
  │ 3. grep "## {category}" in conventions.md                        │
  │    → Read coding/testing/error-handling rules for this domain.   │
  │    → Feed into AGREEMENTS in Context Package.                    │
  │                                                                  │
  │ Fallback (no schema match):                                      │
  │ 4. Codebase itself — grep for similar executor/service/test      │
  │    → read 1 example → extract pattern manually                   │
  └──────────────────────────────────────────────────────────────────┘
  
  What to extract from memory:
  - Approach that worked → reuse directly
  - Approach that failed → explicitly avoid
  - Agreements/style discovered → carry into Context Package

PROBE 3 — Skill & Knowledge Gap Check
  Does the task's domain match a skill I have?
    YES → Load that skill's key rules (don't read 600 lines — grep the relevant section)
    NO  → Is this an unfamiliar domain?
      YES → Search codebase for existing patterns (Probe 2.4)
            If still unclear → consider web search for best practice (RARE — only when
            no codebase precedent AND no memory hit AND domain is genuinely unfamiliar)
      NO  → Proceed with general engineering judgment
```

## Output: Execution Approach (1 paragraph, inline — not a separate doc)

After the 3 probes, synthesize a brief **Execution Approach** that answers:

```
1. APPROACH: "Follow the [X] pattern from [source] — because [reason]"
   Example: "Follow the ChunkedDeleteEngine pattern from PDPC purge — same
   delete-in-chunks + audit-per-chunk approach applies here"

2. STYLE REFERENCE: "[file:method] is the closest parallel — match its structure"
   Example: "SyncPurgeListService.syncKeyBasedList() is the parallel — same
   3-way branch (empty/match/mismatch) pattern"

3. KNOWN PITFALLS: "[lesson from memory/past] — avoid [X], prefer [Y]"
   Example: "line-number-drift lesson — grep ANCHOR before editing, don't trust stale numbers"

4. ADAPTED DECISIONS:
   - If past experience shows THIS type of change needs extra validation → add it
   - If past experience shows THIS type of change is straightforward → simplify
   - If memory says "last time X broke because of Y" → add Y check proactively
```

## Decision Tree: How much effort to spend

```
Task is in a domain I've worked in this session?
  → Probes take <30 seconds: quick memory scan + reuse known approach

Task is in a domain with clear codebase precedent?
  → 1-2 greps to find parallel implementation → extract pattern → proceed

Task is in a truly unfamiliar domain with no precedent?
  → Full 3-probe assessment + potentially load skill + read 1 example thoroughly

NEVER spend more than 3 tool calls on discovery.
If nothing found after 3 probes → proceed with engineering judgment + add extra caution.
```

---

## Memory Schema

Structured memory lets the agent grep the exact category it needs.
Repo memory (`/memories/repo/`) follows this 3-file schema:

```
/memories/repo/
  verified-patterns.md    — approaches that worked (reuse directly)
  failed-approaches.md    — approaches that failed (avoid explicitly)
  conventions.md          — project coding/testing/doc conventions
```

### `verified-patterns.md` format

Each entry is a self-contained pattern that can be copy-adapted:

```markdown
## [domain]: [short name]
- CONTEXT: [when this pattern applies]
- PATTERN: [what to do — key classes, method structure, flow]
- SOURCE: [file:method or memory path where this was proven]
- RESULT: [outcome — e.g., "all tests passed", "production stable"]
```

### `failed-approaches.md` format

```markdown
## [domain]: [what was tried]
- CONTEXT: [when this was attempted]
- APPROACH: [what was done]
- FAILURE: [what went wrong]
- LESSON: [what to do instead]
```

### `conventions.md` format

```markdown
## [category]
- [convention]: [description]
```

Categories: `coding`, `testing`, `error-handling`, `file-io`, `naming`, `doc`

### How probes use the schema

```
PROBE 2 becomes targeted:

  1. Identify domain from task (e.g., "purge")
  2. grep "## purge:" in verified-patterns.md → get matching pattern
  3. grep "## purge:" in failed-approaches.md → get anti-patterns
  4. grep "## testing" in conventions.md → get test agreements
  
  Total: 1-3 grep calls → exact matches → no full-file reads needed
```

### When to write to memory

```
WRITE to verified-patterns.md:
  After implementation passes verification and introduces a new reusable pattern.
  Delegate to @MemoryManager (T3, free).

WRITE to failed-approaches.md:
  When a stop condition triggers and the root cause is an approach choice.
  Record immediately before switching to the correct approach.

WRITE to conventions.md:
  When Adaptive Discovery finds a convention not yet documented.
  Or when a review notes a convention violation — add the correct convention.

NEVER write speculative patterns — only verified outcomes.
```

---

## Integration with other workflows

The Execution Approach output feeds into:
- **plan-to-implementation** → Step 0.5 Skill Matrix AGREEMENTS column, Context Package
- **java-coding / code-improvement** → style reference + known pitfalls
- **Any complex task** → approach + anti-patterns before first edit

```
Task Analysis → Adaptive Discovery → Execution
   (WHAT)       (HOW — from experience)  (DO IT)
```
