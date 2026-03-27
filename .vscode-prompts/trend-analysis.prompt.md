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
- `webSearch` for official announcements, roadmaps, recent releases
- `fetch_webpage` on survey results pages with focused extraction query

### Phase 2: Adoption Signals
- `webSearch` for npm download trends, GitHub stars growth, job postings
- `webSearch` for case studies of companies adopting/migrating to/from this technology
- `webSearch` for "{topic} adoption {current year}" to find recent data

### Phase 3: Community Sentiment
- `webSearch` for "{topic} site:reddit.com r/programming OR r/webdev"
- `webSearch` for "{topic} site:news.ycombinator.com"
- `webSearch` for "{topic} developer experience opinion"
- Look for consensus patterns: What do most developers agree on?

### Phase 4: Emerging Competition
- `webSearch` for alternatives gaining ground
- `webSearch` for "{topic} replaced by OR alternative to {current year}"
- `webSearch` for "awesome-{topic}" curated lists on GitHub

### Phase 5: Expert Predictions
- `webSearch` for conference talks, maintainer blog posts, RFC proposals
- `webSearch` for "{topic} future roadmap plans {current year}"

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
