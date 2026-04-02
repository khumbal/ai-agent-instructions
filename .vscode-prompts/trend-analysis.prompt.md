---
description: "Analyze the current state, trajectory, and future of a technology topic — backed by surveys, community signals, and data."
mode: "agent"
---
# Trend Analysis

You are conducting a trend analysis on a technology topic. Load the `expert-researcher` skill first, then follow the systematic research pipeline.

## Analysis Target
${input}

## Execution Plan

### Phase 1: Current State
- `webSearch` for developer surveys and adoption data (State of JS, Stack Overflow survey, etc.)
- `mcp_chrome-bot-mc_research` for comprehensive multi-source survey data (deep: true, recency: "year")
- `webSearch` for official announcements, roadmaps, recent releases
- `mcp_chrome-bot-mc_news_search` for recent announcements, releases (recency: "month")
- `fetch_webpage` on survey results pages with focused extraction query
- `mcp_chrome-bot-mc_web_fetch_content` for clean full-page extraction

### Phase 2: Adoption Signals
- `webSearch` for npm download trends, GitHub stars growth, job postings
- `mcp_chrome-bot-mc_google_search_ai_overview` for "{topic} adoption" with AI synthesis (recency: "year")
- `webSearch` / `mcp_chrome-bot-mc_duckduckgo_search` for case studies of companies adopting/migrating
- `webSearch` for "{topic} adoption {current year}" to find recent data

### Phase 3: Community Sentiment
- `webSearch` / `mcp_chrome-bot-mc_duckduckgo_search` for "{topic} site:reddit.com r/programming OR r/webdev"
- `webSearch` / `mcp_chrome-bot-mc_duckduckgo_search` for "{topic} site:news.ycombinator.com"
- `webSearch` for "{topic} developer experience opinion"
- `fetch_webpage` / `mcp_chrome-bot-mc_web_fetch_content` on best discussion threads for full context
- Look for consensus patterns: What do most developers agree on?

### Phase 4: Emerging Competition
- `webSearch` / `mcp_chrome-bot-mc_google_search_ai_mode` for alternatives gaining ground (recency: "year")
- `webSearch` for "{topic} replaced by OR alternative to {current year}"
- `webSearch` / `mcp_chrome-bot-mc_duckduckgo_search` for "awesome-{topic}" curated lists on GitHub

### Phase 5: Expert Predictions
- `webSearch` / `mcp_chrome-bot-mc_google_search_ai_overview` for conference talks, maintainer blog posts, RFC proposals
- `webSearch` for "{topic} future roadmap plans {current year}"
- `mcp_chrome-bot-mc_gemini_summarize_youtube` for video conference talks if found

### Phase 6: Synthesize Report

```
## Trend Analysis: {Topic}

### Executive Summary
[State + trajectory in 2-3 sentences]

### Current State ({year})
- Market position
- Adoption level
- Key players/maintainers

### Trajectory
- Growing / Stable / Declining — with evidence
- Key drivers of growth/decline
- Recent inflection points

### Community Sentiment
- What developers love
- Pain points and complaints  
- Migration patterns (to/from)

### Emerging Alternatives
- [Competitor 1]: [why it's gaining ground]
- [Competitor 2]: [why it's gaining ground]

### Risk Assessment
- Risk 1: [specific risk with evidence]
- Mitigation: [suggested approach]

### Prediction (with confidence)
- Short-term (6-12 months): [prediction — confidence level]
- Medium-term (1-3 years): [prediction — confidence level]

### Relevance to Our Project
### Sources
```

**Quality gates:** Distinguish data from opinion. Date all sources. Flag speculative predictions. Include contradicting signals.
