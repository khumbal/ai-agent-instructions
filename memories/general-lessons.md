# General Lessons (decision guidance — not rules)

Insights from past sessions. Use as heuristics when weighing options — not as mandatory steps.
When a lesson conflicts with project context or common sense, project context wins.

## planning
- **line-number-drift** — Line numbers in plans go stale after edits. Consider grepping an anchor string to find current position.

## testing
- **green-tests-not-enough** — Compile + tests pass doesn't always mean done. Worth checking: does the result match the spec? Does it fit existing patterns?

## execution
- **match-surrounding-style** — Glancing at adjacent methods before writing helps maintain consistency in naming, error handling, and patterns.
- **quality-gates-in-sequence** — Compiling before running tests, and testing before moving to next phase, tends to prevent cascading mistakes.
- **clean-up-imports** — After removing code, unused imports are likely. A quick scan avoids noise.

## delegation
- **context-package-matters** — Sub-agents produce better output when given project conventions and anti-patterns, not just the task description.
- **task-tier ↔ model-tier** — Complex reasoning (security, architecture) benefits from premium models. Mechanical tasks (memory ops, boilerplate) work fine on lighter models.

## discovery
- **search-before-creating** — Checking for existing patterns/utils before writing new code often saves effort and keeps the codebase consistent.

## design
- **last-write-wins trap** — When multiple operations update the same field/column, only the last one persists. Flowing all context through one write path avoids silent data loss.
