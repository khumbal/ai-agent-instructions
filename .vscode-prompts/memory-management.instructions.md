---
description: 'Rules for delegating memory operations to @MemoryManager sub-agent (free model, 0 premium cost). Loaded when saving session progress, codebase facts, reviewing memory, or preparing conversation handoff.'
---

# Memory Management

Delegate session/repo memory operations to `@MemoryManager` (free model, 0 premium cost).
User memory (`/memories/`) may be updated directly by the main agent.

## When to Delegate
| Trigger | Action |
|---------|--------|
| Session start (memory files exist) | `@MemoryManager`: read + summarize |
| New codebase facts discovered | `@MemoryManager`: save to repo memory |
| Task completion or phase end | `@MemoryManager`: save progress |
| Long conversation (>10 exchanges) | `@MemoryManager`: save intermediate state |
| Conversation ending | `@MemoryManager`: prepare handoff |

## Briefing Format
```
TASK: save progress | save codebase facts | review memory | prepare handoff
SCOPE: session | repo | all
CONTEXT: [what happened, files changed, key decisions]
RETURN: confirmation | briefing summary | cleanup report
DEPTH: quick
```

## Harvest Protocol (Post-Task)

Before reporting any non-trivial task complete, check: **"did I learn something reusable?"**

| Extract | Target file | Format |
|---------|-------------|--------|
| Pattern that worked | `verified-patterns.md` | `## domain: name` → CONTEXT, PATTERN, SOURCE, RESULT |
| Approach that failed | `failed-approaches.md` | `## domain: name` → CONTEXT, APPROACH, FAILURE, LESSON |
| New convention discovered | `conventions.md` | `## category` → bullet point |

**If YES** → delegate to @MemoryManager:
```
TASK: harvest insights
SCOPE: repo
CONTEXT: [what pattern/failure/convention was discovered, which files]
RETURN: confirmation of what was saved
DEPTH: quick
```

**Skip if:** trivial task (< 5 lines changed), no new domain knowledge, or pattern already in memory.
