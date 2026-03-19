---
name: agent-session-review
description: "Audit AI agent session quality — reviews conversation history to assess goal alignment, planning discipline, delegation efficiency, anti-loop behavior, over-engineering avoidance, and memory usage. Produces strengths, weaknesses, actionable rules, and memory updates. Use when user says 'review session', 'audit agent', 'วิเคราะห์ session', 'agent ทำงานเป็นยังไง', or after completing complex multi-phase work."
argument-hint: "The session or conversation to review"
metadata:
  author: phumin-k
  version: "1.0"
  scope: "**"
  tier: T1
  triggers:
    - "review session"
    - "audit agent"
    - "วิเคราะห์ session"
    - "agent performance"
    - "process review"
    - "what went well"
    - "improve agent"
---

# Agent Session Review

> **Metacognition**: Step outside the agent role and evaluate how the agent performed — not what code it wrote, but how it reasoned, decided, and executed.

## When to use this skill

- After completing complex multi-phase work (≥3 phases)
- When user asks to review session quality or agent behavior
- When user wants to extract lessons for future sessions
- After a session where things went wrong (loops, over-engineering, misunderstanding)
- Periodic self-assessment to improve agent configuration

## Review Philosophy

**Evidence over opinion.** Every finding must cite a concrete action (tool call, delegation, re-read, plan change) from the session. No vague "could have been better" without pointing to what happened.

**Process review, not code review.** This skill evaluates how the agent worked, not the correctness of the code it produced. Code quality is handled by `code-review` skill.

**Balanced assessment.** Always identify both strengths and weaknesses. Pure criticism without acknowledging what worked is as unhelpful as pure praise.

---

## Review Framework: 6 Dimensions

### Dimension 1: Goal Alignment
Did the agent understand and stay focused on the user's actual intent?

**Evidence to check:**
- Did the agent restate or clarify the goal before acting?
- Did the work produced match what the user asked for?
- Did the agent respect explicit constraints (e.g., "don't over-engineer", "useful only")?
- Did the agent drift toward related-but-unasked work?

**Scoring:**
- ✅ Strong: Goal understood correctly, constraints respected, no drift
- ⚠️ Mixed: Goal understood but mild drift or constraint ignored partway
- ❌ Weak: Misunderstood goal, significant drift, or constraints violated

### Dimension 2: Planning Discipline
Did the agent plan efficiently without over-analysis?

**Evidence to check:**
- Was the plan right-sized? (2-3 items, not 7 candidates slowly discarded)
- Did the agent apply `analysis-stop-rule`? (file + change + reason known → implement)
- Did the agent use `convergence-gate`? (implement / defer / reject — no re-survey)
- Was plan and implementation in the same pass, or split across turns?

**Anti-patterns to detect:**
- Opening many candidates then slowly eliminating → over-analysis
- Reading the same files multiple times across turns
- "Re-survey for confidence" without new evidence
- Planning in turn N, implementing in turn N+1 (forces full re-read)

### Dimension 3: Delegation Quality
Did the agent use sub-agents appropriately — and skip them when unnecessary?

**The core question: Was delegation cost-justified?**
Every delegation has a cost (tokens, latency, context loss) and a benefit (parallel work, fresh perspective, scope isolation). The reviewer must assess whether the benefit exceeded the cost for each delegation call in the session.

**Delegation Decision Matrix (use to judge each call):**

```
BEFORE delegating, the agent should have answered:

Q1: Is the scope genuinely unknown?
    YES (≥3 unfamiliar files, no summary context) → Explore justified
    NO  (summary has file paths + methods + rationale) → Do it yourself

Q2: What's the information gain vs. cost?
    HIGH gain (cross-file architecture, ≥3 unknown files) → Delegate
    LOW gain  (scope known, need 1-2 targeted reads) → Direct execution
    ZERO gain (re-exploring what summary already provides) → WASTE

Q3: Could main agent do this in ≤3 tool calls?
    YES → Don't delegate. grep + read ±20 lines + edit = done.
    NO  → Delegation may be justified if scope is truly complex.

Q4: Is the delegation prompt specific enough?
    Has TASK + SCOPE + CONTEXT + RETURN + DEPTH → Good
    Missing any → Sub-agent will produce generic/unfocused output
```

**Context Availability Test (the sharpest criterion):**
When the conversation summary already contains:
- ✓ Exact file paths
- ✓ Method names and signatures
- ✓ Rationale for changes
- ✓ Known constraints

Then delegation adds near-zero information. The agent should:
1. Grep anchor string to find current line number
2. Read ±20 lines for exact context
3. Implement directly

Launching Explore in this state = **cost without information gain**.

**Evidence to check:**
- Was Explore used only for genuinely unknown scope (≥3 unfamiliar files)?
- Did Explore prompts include TASK/SCOPE/CONTEXT/RETURN/DEPTH?
- Was the sub-agent output used efficiently (not re-read via read_file)?
- Was delegation skipped when summary already had full context?
- Was the right tier used? (T1 for reasoning, T2 for implementation, T3 for mechanical)
- Did the agent assess information gain vs. cost before delegating?

**Anti-patterns to detect:**
- **Exploring known scope** — summary has files + methods + rationale, but Explore launched anyway
- **Low-leverage delegation** — Explore returns useful but not essential info; main agent could have done it in 2 calls
- **Single symbol lookup via Explore** — use `vscode_listCodeUsages` instead
- **Re-reading Explore output** — read_file on sub-agent temp file instead of using returned message
- **Missing Context Package** — no conventions, no anti-patterns in delegation prompt
- **Tier mismatch** — T1 reasoning task delegated to T3 agent, or T3 mechanical task on main agent
- **Broad delegation scope** — "full structural inventory" when only 2-3 specific answers needed
- **No scope narrowing** — could have asked 1 focused question but asked for everything

**Scoring:**
- ✅ Strong: Every delegation was cost-justified; skipped delegation when context was available
- ⚠️ Mixed: Delegation produced useful output but was avoidable given available context
- ❌ Weak: Multiple delegations with near-zero information gain, or critical delegations missing

### Dimension 4: Execution Efficiency
Did the agent use tokens wisely?

**Evidence to check:**
- Did the agent read content once and reuse, or re-read same files?
- Were independent tool calls batched in parallel?
- Were edits batched via multi_replace when possible?
- Was terminal output piped through `head`/`tail`?
- Did the agent use grep → read ±20 lines, or read full files?

**Anti-patterns to detect:**
- Same file read 3+ times across turns
- Sequential tool calls that could have been parallel
- Todo updates for every small step (>3 updates)
- Full file reads for 150+ line files without grep first

### Dimension 5: Anti-Loop & Over-Engineering
Did the agent avoid wasted cycles and unnecessary complexity?

**Evidence to check:**
- Did the agent try a failed approach more than once?
- Did the agent add features/abstractions not requested?
- Were refactor candidates tested with `consumer-value-test`?
- Were candidates killed early when they failed kill criteria?
- Did the agent apply user constraints as design filters upfront?

**Anti-patterns to detect:**
- Same approach retried after failure (should switch strategy)
- Extracting utility classes for single consumers
- Merging overloads that worsen caller readability
- Adding loops for speculative multi-instance scenarios
- "Just in case" error handling beyond system boundaries

### Dimension 6: Memory & Learning
Did the agent use and update memory effectively?

**Evidence to check:**
- Was `adaptive-discovery` used before complex work? (check repo memory)
- Were new lessons captured after significant work?
- Were lessons categorized correctly? (general vs repo-specific)
- Was repo memory consulted for conventions/patterns/anti-patterns?
- Are lessons actionable and concise, not verbose?

**Anti-patterns to detect:**
- Repo memory empty after 10+ phases of work
- Lessons duplicated across memory files
- Verbose lessons that won't be grepped effectively
- Missing failed-approaches that could prevent repeating mistakes

---

## Execution Procedure

### Step 1: Gather Evidence
Source material for the review:
1. **Conversation summary** — the primary source (phases, decisions, tool calls)
2. **Memory files** — what was learned/stored (`/memories/` all scopes)
3. **Instructions/Skills** — the rules the agent should have followed

Do NOT re-read source code files. This is a process review, not a code review.

### Step 2: Score Each Dimension
For each of the 6 dimensions:
1. Find 1-3 concrete evidence points (positive or negative)
2. Assign score: ✅ Strong / ⚠️ Mixed / ❌ Weak
3. Write 1-2 sentence justification with specific evidence

### Step 3: Identify Top Findings
Extract:
- **Top 3 strengths** — what went well, with evidence
- **Top 3 weaknesses** — what went wrong, with evidence
- **Root cause** for each weakness — why did this happen?

### Step 4: Produce Actionable Rules
For each weakness, produce a concrete rule:
- Format: `**rule-name** — description (1 line)`
- Must be specific enough to apply in future sessions
- Must not duplicate existing lessons in memory

### Step 5: Memory Update Recommendations
Determine what should be saved:
- New lessons → which file? (`general-lessons.md` or `repo/`)
- Existing lessons to update → which ones?
- Duplicate lessons to deduplicate → where?

### Step 6: Determine if Instructions/Skills Need Updates
Check whether any finding should be promoted:
- Memory = heuristics (soft guidance, accumulated wisdom)
- Instructions = workflow structure (always-on, identity)
- Skills = domain workflows (on-demand, triggered by task type)

**Promotion criteria:**
- Memory → Instructions: Only if it's a structural behavior change, not a heuristic
- Memory → Skill: Only if it's a repeatable multi-step workflow
- Most lessons stay in memory — don't over-promote

---

## Output Format

```markdown
## Session Review: [session description]

### Overall Verdict: [Excellent / Good / Mixed / Weak]

### Dimension Scores
| Dimension | Score | Key Evidence |
|-----------|-------|-------------|
| Goal Alignment | ✅/⚠️/❌ | [1 sentence] |
| Planning Discipline | ✅/⚠️/❌ | [1 sentence] |
| Delegation Quality | ✅/⚠️/❌ | [1 sentence] |
| Execution Efficiency | ✅/⚠️/❌ | [1 sentence] |
| Anti-Loop & Over-Eng | ✅/⚠️/❌ | [1 sentence] |
| Memory & Learning | ✅/⚠️/❌ | [1 sentence] |

### Top 3 Strengths
1. **[name]** — [evidence]
2. **[name]** — [evidence]
3. **[name]** — [evidence]

### Top 3 Weaknesses
1. **[name]** — [evidence] → Root cause: [why]
2. **[name]** — [evidence] → Root cause: [why]
3. **[name]** — [evidence] → Root cause: [why]

### Actionable Rules
- **[rule-name]** — [description]
- **[rule-name]** — [description]

### Memory Updates
- [ ] Add to `general-lessons.md`: [lesson]
- [ ] Add to `repo/verified-patterns.md`: [pattern]
- [ ] Add to `repo/failed-approaches.md`: [approach]
- [ ] Deduplicate: [what overlaps]

### Promotion Assessment
- [None needed / Specific recommendation with rationale]
```

---

## Rules

- **Evidence-based only** — never report a finding without citing a specific action from the session
- **No code inspection** — this reviews process, not code correctness
- **Balanced** — always report both strengths and weaknesses
- **Concise** — each finding is 1-2 sentences, not paragraphs
- **Actionable** — every weakness has a corresponding rule or memory update
- **No self-congratulation** — if verdict is "Excellent", verify with evidence (it's rare)
- **Respect existing memory** — check what's already captured before recommending new lessons
