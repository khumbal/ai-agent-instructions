---
description: "Principles for writing focused, agent-readable documentation — no filler, no duplication, every section earns its place. Loaded when writing, editing, reviewing, or restructuring documentation files. Triggered by: write docs, เขียนเอกสาร, clean docs, review docs, update docs, restructure docs."
applyTo: "**/*.md"
---

# Documentation Writing — Focused & Agent-Readable

Write documentation that helps both humans and AI agents understand a system quickly. Every sentence must earn its place — if removing it doesn't reduce understanding, delete it.

## Core Principle: Code Is the Source of Truth

Documentation exists to explain what **code cannot show** — reasoning, constraints, coupling relationships, and design decisions. Never duplicate what a developer (or agent) can discover by reading the code.

**Write this:**
- Why a decision was made (the reasoning behind constraints)
- What breaks when X changes (coupling maps)
- Invariants that aren't obvious from code structure
- Mental models that help navigate the codebase

**Don't write this — it's already in the code:**
- Full type/schema definitions (point to the file)
- Function signatures or parameter lists
- Sequence diagrams that just restate the call chain
- File maps listing every source file
- Metrics thresholds, exact numbers, config values
- Component tables listing every function in a module

## Document Ownership: Single Source of Truth

Every piece of information lives in exactly ONE document. Other docs reference it — never copy it.

### Before writing, answer:
1. **Does another doc already own this?** → Link to it, don't duplicate
2. **What does THIS doc uniquely own?** → State it explicitly in a boundary section
3. **Who reads this doc and when?** → Shape content for that reader at that moment

### Document Boundary Pattern
Every doc with potential overlap should declare its scope at the top:

```markdown
> **Document boundary**: This document owns [X, Y, Z].
> For [A], see [other-doc]. For [B], see [another-doc].
```

This prevents gradual drift where docs accumulate each other's content over time.

## Three-Tier Documentation Model

| Tier | Purpose | Contains | Avoids |
|------|---------|----------|--------|
| **Concept** | Why the system exists, mental model | Philosophy, metaphors, design principles | Implementation details, code references |
| **Design** | How subsystems work, contracts | Schemas, state machines, error handling rules | Full pipeline narrative, operational procedures |
| **Reference** | Where things are, runtime shape | Module map, phase hand-offs, config reference | Subsystem internals already in Design tier |

When a doc tries to be two tiers at once, it gets long and repetitive. Pick one tier per document.

## Agent-Readable Format

AI agents consume docs differently than humans — they need structure, not prose. Optimize for scanability:

### Do:
- **Tables** for relationships, coupling maps, decision matrices
- **Short code blocks** (≤10 lines) for flow visualization
- **"Why" sections** explaining the reasoning behind each major constraint
- **Coupling alerts**: "Changing X requires updating Y, Z" — agents need this to avoid partial changes
- **Labeled sections** with consistent heading hierarchy — agents navigate by heading

### Don't:
- Long narrative paragraphs — break into bullet points or tables
- Deeply nested subsections (>3 levels) — flatten with clear section names
- Inline code mixed with prose — separate into standalone blocks
- Redundant context ("As mentioned in the previous section...") — agents don't read linearly

## Cutting "Water" (Filler) — Decision Checklist

Before writing a section, apply these filters:

| Question | If YES |
|----------|--------|
| Can an agent discover this by reading the source file? | Don't write it — at most, point to the file |
| Does this repeat content from another doc? | Link, don't copy |
| Is this a sequence diagram of a straightforward call chain? | Delete — `grep` the code instead |
| Is this a table listing every function in a module? | Delete — IDE navigation is faster |
| Are these exact threshold numbers or config values? | Point to config file — values change, docs go stale |
| Does removing this section reduce system understanding? | If no → delete |

## When Editing Existing Docs

1. **Read all related docs first** — understand what's already documented where
2. **Identify overlap** — grep for the same concept/type/contract names across docs
3. **Assign ownership** — decide which doc owns each piece of duplicated content
4. **Trim, don't move** — delete the duplicate; don't relocate text that already exists elsewhere
5. **Add boundary declarations** — prevent re-accumulation of overlap
6. **Verify references** — after trimming, ensure remaining docs still link to the authoritative source

## Anti-Patterns

- **"Comprehensiveness" trap**: Trying to document everything in one place. Result: 1000-line doc that no one reads and is always stale.
- **Copy-paste evolution**: Two docs start similar, diverge slowly, now both are "almost right" but subtly different. Fix: pick one owner, delete the other's version.
- **Diagram addiction**: A sequence diagram for every interaction. Most add no value over reading the 20-line function. Keep diagrams for non-obvious multi-system flows only.
- **Premature documentation**: Documenting designs before they're implemented. Result: docs that describe a system that doesn't exist. Write docs *after* the code works.
- **Changelog-as-doc**: Documenting the history of changes instead of the current state. Docs describe what IS, not what WAS. Git has history.
