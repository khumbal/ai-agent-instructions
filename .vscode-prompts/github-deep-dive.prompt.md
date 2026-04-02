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
- `fetch_webpage` / `mcp_chrome-bot-mc_web_fetch_content` the repo's main page for purpose, architecture, design philosophy
- `webSearch` / `mcp_chrome-bot-mc_google_search_ai_overview` for external articles explaining the project (recency: "year")

### Phase 2: Architecture & Source Structure  
- `fetch_webpage` / `mcp_chrome-bot-mc_web_fetch_content` the source directory structure
- `github_repo` searching for architecture, design, patterns, core abstractions
- If docs/ exists, read architecture docs via `fetch_webpage` (query: "design") or `mcp_chrome-bot-mc_web_fetch_content`

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
- Then `fetch_webpage` (with focused `query`) or `mcp_chrome-bot-mc_web_fetch_content` with **raw.githubusercontent.com** URLs to read full source
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
- `webSearch` / `mcp_chrome-bot-mc_google_search_ai_overview` for tutorials, blog posts explaining the project internals (recency: "year")
- `webSearch` / `mcp_chrome-bot-mc_duckduckgo_search` for community sentiment — "site:reddit.com OR site:news.ycombinator.com"
- `webSearch` / `mcp_chrome-bot-mc_research` for alternatives and how this project differs

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
