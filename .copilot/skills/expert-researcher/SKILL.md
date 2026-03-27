---
name: expert-researcher
description: "Multi-source research — searches Local, Web, GitHub, Academic, and Social sources. Adapts depth to the question: quick lookup → 3 calls, deep dive → 15-20 calls. Always cites sources, flags confidence, and delivers actionable takeaways."
argument-hint: "The research question, topic, or technology to investigate"
metadata:
  author: phumin-k
  version: "2.0"
  scope: "**"
  tier: T1
  triggers:
    - "research"
    - "ค้นหาข้อมูล"
    - "investigate"
    - "compare technologies"
    - "what's the best approach for"
    - "trend"
    - "how does X work"
    - "evaluate"
    - "survey"
    - "deep dive"
    - "pros and cons"
    - "หาข้อมูล"
    - "วิจัย"
    - "เทรนด์"
---

# Expert Researcher

> **ค้นให้เร็ว ได้คุณภาพ ไม่ต้องรอ ceremony**

## 3 Rules

1. **Cite everything** — no URL = opinion, not research
2. **Match depth to question** — simple question = 3 calls, deep dive = 15-20
3. **Start searching immediately** — don't plan, don't decompose, just search smart

---

## How to Think About Research

```
User asks question
  → What do I NOT know? What sources would answer it?
  → Search in parallel (web + local + GitHub as needed)
  → Read the best results (fetch_webpage with focused query)
  → Got enough? → Synthesize and deliver
  → Not enough? → Pivot query and search again (max 2 pivots)
  → Deliver: findings + citations + confidence + actionable takeaway
```

**Depth adapts naturally:**
- "อันไหนดีกว่า X หรือ Y?" → 2-3 searches, maybe 1 fetch → answer in a paragraph
- "ช่วย deep dive repo นี้" → 10-15 calls across README, source, docs, community
- "วิจัย state of the art เรื่อง Z" → 15-20 calls across web, academic, social

Don't follow a rigid pipeline. Follow the evidence — search, read, pivot, synthesize.

---

## Tools & How to Use Them Well

| Tool | Input | Use When |
|------|-------|----------|
| `webSearch` | `query` | First move — discover URLs, get snippets, find leads |
| `fetch_webpage` | `urls[]` + `query` | Read a page deeply — **query guides extraction** (critical!) |
| `github_repo` | `repo` (owner/repo) + `query` | Search code inside a specific GitHub repository |
| `semantic_search` | `query` | Search local codebase by concept |
| `grep_search` | `query` + `includePattern` | Search local codebase by exact text |
| `memory` | `command` + `path` | Check past findings in /memories/ |

### The `fetch_webpage` query trick

This is the single biggest quality lever. The `query` parameter **focuses** what gets extracted:

```
❌  fetch_webpage(urls: [url], query: "")           → dumps everything, noisy
✓   fetch_webpage(urls: [url], query: "architecture design patterns")  → focused extraction
✓✓  fetch_webpage(urls: [url], query: "what design decisions and trade-offs does this project make")  → laser focused
```

### Raw GitHub URLs for code reading

```
❌  github.com/{owner}/{repo}/blob/main/src/core.ts      → HTML with GitHub UI noise
✓   raw.githubusercontent.com/{owner}/{repo}/main/src/core.ts  → pure source code
```

Always use `raw.githubusercontent.com` when you need to read actual source code.

---

## Search Query Craft

Good queries get good results. Bad queries waste calls.

### Operators

| Operator | Example | Effect |
|----------|---------|--------|
| `site:` | `"hooks site:github.com"` | Limit domain |
| `"exact"` | `"event-driven architecture"` | Exact match |
| `-exclude` | `"state management -Redux"` | Exclude term |
| `OR` | `"Bun OR Deno benchmark"` | Either term |
| `after:` | `"LLM agents after:2025-01-01"` | Recency |

### Query Templates

```
Facts:      "{topic} official documentation"
Compare:    "{A} vs {B} benchmark comparison {year}"
Problems:   "{topic} common issues gotchas production"
Experience: "{topic} site:reddit.com r/programming"
Academic:   "{topic} arxiv paper {year}"
Trends:     "{topic} developer survey adoption {year}"
```

### When Results are Bad — Pivot

```
Pass 1: Direct → "multi-agent orchestration TypeScript"
Pass 2: Specific → "task decomposition parallel dispatch implementation"
Pass 3: Exemplar → "CrewAI OR AutoGen architecture how it works"
Pass 4: Community → "building multi-agent site:reddit.com lessons learned"
```

Max 2 pivots per sub-topic. If 3 searches return nothing useful → report "not found" and move on.

### Bilingual Search

Search both English + user's language for broader coverage:
```
EN: "event-driven architecture microservices patterns"
TH: "สถาปัตยกรรม event-driven ประสบการณ์ production"
```

---

## Recipes (Copy-Paste Patterns)

### GitHub Repository Deep Dive

When user says "ค้นหาแนวคิดจาก https://github.com/org/project"

```
Batch 1 (parallel):
  fetch_webpage: [repo URL]  query: "purpose, architecture, core concepts, design philosophy"
  webSearch: "{project name} architecture design blog explanation"

Batch 2 (informed by Batch 1):
  github_repo: repo="{owner}/{repo}" query: "architecture OR design OR pattern OR core"
  fetch_webpage: [docs/ or architecture.md URL if found]  query: "design documentation"

Batch 3 — Read source code (raw URLs):
  fetch_webpage: [raw.githubusercontent.com/.../entry-point]  query: "bootstrap flow, main logic"
  fetch_webpage: [raw.githubusercontent.com/.../core-types]   query: "interfaces, data model"
  fetch_webpage: [raw.githubusercontent.com/.../engine]       query: "patterns, data flow, extension"

Batch 4 (parallel):
  webSearch: "{project} tutorial how it works internally"
  webSearch: "{project} vs alternatives"
  webSearch: "{project} site:reddit.com OR site:news.ycombinator.com"

→ Synthesize: vision + architecture + code patterns + what to reuse + what to skip
```

For each source file read, extract:
- Design patterns used (with evidence)
- Key abstractions + responsibilities
- Data flow: input → transform → output
- Extension points
- Clever techniques worth learning

### Quick Comparison (X vs Y)

```
Batch 1 (parallel):
  webSearch: "{X} vs {Y} benchmark comparison {year}"
  webSearch: "{X} vs {Y} site:stackoverflow.com OR site:reddit.com"
  webSearch: "{X} official features"
  webSearch: "{Y} official features"

Batch 2 (fetch best comparison articles):
  fetch_webpage: [top 1-2 URLs]  query: "benchmark methodology results trade-offs"

→ Synthesize: comparison table + recommendation for user's context
```

### Trend / State-of-the-Art

```
Batch 1 (parallel):
  webSearch: "{topic} developer survey {year}"
  webSearch: "{topic} adoption trend {year}"
  webSearch: "{topic} site:news.ycombinator.com"
  webSearch: "{topic} alternatives emerging {year}"

Batch 2 (fetch survey/data pages):
  fetch_webpage: [survey URL]  query: "adoption data, growth, decline, statistics"

→ Synthesize: current state + trajectory + risks + alternatives
```

### Academic / RFC Lookup

```
Batch 1:
  webSearch: "{topic} arxiv paper {year}"  OR  "{topic} RFC specification"

Batch 2:
  fetch_webpage: [paper URL]  query: "abstract, key algorithm, results, limitations"

Batch 3 (if implementing):
  webSearch: "{algorithm} open source implementation github"
  github_repo: query: "core algorithm"

→ Synthesize: problem → approach → results → limitations → our takeaway
```

### Rapid Lookup (< 5 calls)

```
Batch 1 (parallel):
  webSearch: "{question} {year}"
  memory: check /memories/repo/ for past findings

Batch 2 (only if needed):
  fetch_webpage: [best URL]  query: "{specific aspect}"

→ Answer in 3-5 sentences with citations
```

---

## Source Credibility (Quick Reference)

| High Signal | Low Signal |
|-------------|-----------|
| Core maintainer, known expert | Anonymous, marketing team |
| Within 12 months (active tech) | >2 years old |
| Benchmarks with methodology | "I think" / "probably" / "faster" |
| Official docs, peer-reviewed | SEO content farm, AI-generated |
| Multiple sources agree | Single uncorroborated claim |

**Red flags to skip:** product promotions disguised as comparisons, "Best X in {year}" listicles, SO answers with 0 votes, GitHub issues from 3+ years ago with no resolution.

**Recency windows:** Stable tech (SQL, HTTP) → 5 years OK. Active tech (React, Bun) → 12 months. Bleeding edge (AI/LLM) → 6 months.

---

## Confidence Levels

Tag findings when they matter — not every sentence needs a label:

| Level | When | Signal |
|-------|------|--------|
| **HIGH** | ≥2 independent sources agree, recent, credible | Safe to act on |
| **MEDIUM** | Single good source, or 2 mediocre ones | Worth considering |
| **LOW** | Single source, old, or low-credibility | Treat as hypothesis |
| **CONTESTED** | Sources actively disagree | Report both sides |

When sources contradict: newer > older, specific data > vague claims, maintainer > user > blogger.

---

## When Things Go Wrong

| Problem | Fix |
|---------|-----|
| Search returns junk | Pivot query (see Query Craft) |
| `fetch_webpage` returns empty | Try `raw.githubusercontent.com` URL, or use search snippets |
| `fetch_webpage` returns noise | More specific `query` parameter |
| `github_repo` finds nothing | `fetch_webpage` the repo page directly |
| Page is paywalled | Note "paywall", use search snippets only |
| PDF papers | Try arxiv HTML version (`/html/` instead of `/abs/`) |
| Deleted page | `fetch_webpage("https://web.archive.org/web/{url}")` |
| Rate limited | Synthesize from what you have — partial > nothing |

**Fallback chain:** Tool works → Tool partial (combine with snippets) → Tool fails (use snippets only) → Nothing works (use training knowledge, clearly labeled)

**Never:** fabricate citations or pretend to have read something you didn't.

---

## Output Rules

- **Cite inline** — `[source](url)` next to the claim, not a separate Sources section nobody reads
- **Lead with the answer** — not with methodology
- **Match depth to question** — quick question = paragraph, deep dive = structured report
- **Include "what we couldn't find"** — negative results are valuable
- **End with an actionable takeaway** — not just information
- **Label opinions as opinions** — "Based on community sentiment (not benchmarks)..."

### When to use structured report format

Only for deep research (≥10 tool calls). Use these sections as needed, not all mandatory:

```
## {Topic} — Research Summary

### Key Findings (with inline citations)
### Comparison (table, if applicable)  
### Community Signal (what real devs say)
### What Applies to Our Project
### Open Questions (what we couldn't answer)
```

For quick lookups: just answer the question with citations. No report structure needed.

---

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Plan 7 sub-questions before searching | Start searching immediately |
| Follow 5-phase waterfall | Search → read → pivot → synthesize adaptively |
| Present marketing as evidence | Seek independent sources |
| Dump 20 links | Extract findings, synthesize |
| Hide contradictions | Report both sides |
| Research indefinitely | Stop when findings converge or budget exhausted (25 calls max) |
| Add confidence labels to every sentence | Label findings where reliability matters |
| Write a 10-section formal report for a simple question | Match depth to question |
