---
description: "Evaluate a technology, framework, or tool for adoption — multi-source comparison with evidence-backed recommendation."
mode: "agent"
---
# Technology Evaluation

You are conducting a rigorous technology evaluation. Load the `expert-researcher` skill first, then follow the systematic research pipeline.

## Evaluation Target
${input}

## Execution Plan

### Phase 1: Decompose
Break the evaluation into sub-questions:
- Q1: What is it and what problem does it solve? (official docs)
- Q2: How mature and actively maintained? (GitHub activity, releases, funding)
- Q3: What are known problems/limitations? (GitHub issues, Stack Overflow)
- Q4: How does it compare to alternatives? (benchmarks, comparisons)
- Q5: What do experienced users say? (community signal — Reddit, HN, X)
- Q6: Does it fit our tech stack and requirements? (local codebase analysis)

### Phase 2: Gather Evidence
Use parallel tool chains — choose tools that best fit each query:
- `webSearch` for official positions + external comparisons
- `mcp_chrome-bot-mc_research` for comprehensive multi-source search (deep: true, recency: "year")
- `mcp_chrome-bot-mc_google_search_ai_overview` for AI-synthesized answers on focused questions (recency: "year")
- `fetch_webpage` on best comparison articles (use focused query)
- `mcp_chrome-bot-mc_web_fetch_content` for clean full-page extraction
- `mcp_chrome-bot-mc_duckduckgo_search` for community experience ("site:reddit.com", "site:github.com")
- `mcp_chrome-bot-mc_news_search` for recent announcements (recency: "month")
- `semantic_search` / `grep_search` for local codebase compatibility

### Phase 3: Validate
- Cross-reference findings across ≥2 sources
- Flag vendor marketing vs independent evidence
- Check source dates (≤12 months for active tech)

### Phase 4: Synthesize Report

```
## Technology Evaluation: {name}

### Executive Summary
[2-3 sentences: recommendation + confidence level]

### What It Is
### Maturity & Ecosystem Health
### Comparison Matrix
| Aspect | {Tech A} | {Tech B} | {Tech C} |
|--------|----------|----------|----------|

### Community Signal (real developer experience)
### Known Limitations & Risks
### Fit with Our Project
### Recommendation
### Sources
```

**Quality gates:** Confidence levels on every finding. Cite all claims. Report contradictions. Include negative results.
