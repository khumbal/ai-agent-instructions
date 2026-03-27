---
description: "Deep dive research into a GitHub repository — extract architecture, design patterns, core concepts, and actionable insights for your own project."
mode: "agent"
---
# GitHub Repository Deep Dive

You are conducting a thorough research of a GitHub repository. Load the `expert-researcher` skill first, then follow the **GitHub Repository Deep Dive** recipe from the Tool Composition Recipes section.

## Research Target
${input}

## Execution Plan

### Phase 1: Overview & README
- `fetch_webpage` the repo's main page with query focused on "purpose, architecture, core concepts, design philosophy"
- `webSearch` for external articles explaining the project

### Phase 2: Architecture & Source Structure  
- `fetch_webpage` the source directory structure
- `github_repo` searching for architecture, design, patterns, core abstractions
- If docs/ exists, read architecture docs via `fetch_webpage`

### Phase 3: Read & Interpret Core Source Code
This is the critical phase — actually reading the code, not just descriptions.

**Strategy: Use raw URLs for clean code reading:**
```
# Raw URL pattern (no HTML noise, pure source code):
https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{path}

# Example:
https://raw.githubusercontent.com/alibaba/hiclaw/main/src/core/engine.ts
```

- Use `github_repo` first to **discover** key files (entry points, core modules, type definitions) 
- Then `fetch_webpage` with **raw.githubusercontent.com** URLs to read full source
  - Use focused `query` like: "design patterns, key abstractions, data flow"
- Read in priority order:
  1. **Entry point** (main, index, app) — understand the bootstrap flow
  2. **Core types/interfaces** — understand the data model and contracts
  3. **Main engine/orchestrator** — understand the central logic
  4. **Extension/plugin system** — understand how it's designed to grow
- For each file, extract:
  - Design patterns used (Factory, Strategy, Observer, Pipeline, etc.)
  - Key abstractions and their responsibilities
  - Data flow: input → transform → output
  - Extension points: how would a developer add new capabilities?
  - Clever techniques worth learning from

### Phase 4: External Context
- `webSearch` for tutorials, blog posts explaining the project internals
- `webSearch` for community sentiment (Reddit, HN)
- `webSearch` for alternatives and how this project differs

### Phase 5: Synthesize Report

Deliver the report in this structure:

```
## {Project} — Research Summary

### Purpose & Philosophy
### Architecture (with diagram if possible)
### Key Design Patterns (with code evidence)
  - For each pattern: what it is, where in the code, why it matters
### Code Quality & Style Observations
  - What the codebase does well technically
  - Interesting implementation techniques
### What We Can Reuse / Learn From
  - Specific concepts with concrete adaptation ideas
### What We Should NOT Copy (and why)
### Maturity Assessment
### Relevance to Our Project
### Sources (include raw file URLs for key code references)
```

**Quality gates:** Every finding needs a citation. Include confidence levels. Separate facts from opinions. Note what you couldn't access.
