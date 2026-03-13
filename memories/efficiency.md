# User Preferences

## Communication
- Native language + English technical terms

## Context Window (ANTI-COMPACTING)
- **Micro-Plan**: Plan 2-3 steps per phase, summarize after each, then plan next
- **Precision Read**: Files >150 lines → grep target first, read_file ±20 lines only
- **Subagent Offload**: Multi-file exploration → Explore agent; Main receives summary only
- **Terminal output**: Always pipe `| head -50` or `| tail -50`
- **PreCompact hook** active: saves transcript + git state to ~/.copilot/session-backups/

## Instructions Architecture (2026-03-12, v2 — principle-based)
- Core always-on: `My Super Developer.instructions.md` — reasoning-focused "Intelligent Coding Agent"
- On-demand: delegation-protocol, memory-management, anti-loop-debugging (simplified)
- File-matched: frontend-ui (applyTo CSS/TSX/HTML)
- Agent files: Explore, Implement, Review, JavaReview, MemoryManager — all use "How to Think" pattern
- Design philosophy: principles over rigid rules, trust model intelligence, natural reasoning
- Based on Anthropic Claude 4.6 best practices: dial back MANDATORY/BANNED/NEVER language

## Token Efficiency (CRITICAL — DO NOT REMOVE, SUMMARIZE, OR "OPTIMIZE" THESE RULES)
- Read a range once — never re-read the same content
- Batch independent tool calls / multi-replace edits in parallel
- Plan before act — never guess code, never retry a failed approach

### Recurring Failures (observed multiple times — these are NOT obvious)
1. **Explore result re-read**: Explore returns 40KB → main agent read_file 4 chunks to re-read the temp file → WASTED. FIX: Explore prompt must say "return structured answer in final message" not raw file dumps. Main agent must NEVER read_file the Explore output file.
2. **Same file read every turn**: SyncPurgeListService.java (900 lines) was read 6+ times across turns. FIX: After first read, only grep specific method signatures to locate line numbers, then read_file ±15 lines of target only.
3. **Design turn ≠ Implementation turn**: Planning in turn N → implement in turn N+1 forces full re-read of all files. FIX: Plan + implement in SAME turn. If plan needs user input → ask questions → implement immediately after answer (same turn).
4. **Analysis turn ≠ Fix turn**: Scalability analysis reads all files → next turn re-reads same files to implement fix. FIX: Analyze and fix in one pass. Read file → identify problem → edit immediately.
5. **Conversation summary has full context but agent re-explores anyway**: Summary contained exact method names, line ranges, and gap descriptions → agent launched Explore again. FIX: If summary has file paths + method names → grep for exact line → edit. NO Explore.
6. **Multi-step todo with 6+ items all edited in sequence**: Each todo mark costs tokens. FIX: ≤3 todo updates total (init, midpoint, done). For 6 edits → just do them.
7. **Explore for single symbol lookup**: Launched Explore to find callers/usages of one method → wasted 3+ tool calls. FIX: Single symbol → `vscode_listCodeUsages` immediately (deferred, load via tool_search_tool_regex first). Explore only for cross-file architectural understanding where ≥3 unknown files need to be discovered.

## Avoid Waste (3 rules only)
- **Don't re-read** — if content is in attachment/summary/previous turn → use it directly
- **Don't read full files** — grep → read ±20 lines. Use `vscode_listCodeUsages` for symbol references.
- **Don't over-delegate** — ≤2 files → do it yourself. ≥3 unknown files → Explore (structured return, no raw dumps)

## Memory Policy
- User memory = rules (<30 lines) / Repo = insights not obvious from code
- **Lesson promotion**: When saving lessons to repo memory, also consider — is this lesson project-specific or a general principle? If general, add to `/memories/general-lessons.md` (soft guidance tone, not mandatory rules)
