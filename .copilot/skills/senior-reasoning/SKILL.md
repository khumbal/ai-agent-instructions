---
name: senior-reasoning
description: "Structured reasoning framework for making high-quality decisions — evaluates consumer impact, cost/benefit, evidence strength, and proportionality before committing to an approach. Prevents over-analysis, unjustified complexity, and decisions based on speculation. Use when facing trade-offs, evaluating multiple options, deciding scope/depth, or when reasoning feels circular — even if the user just says 'think about this', 'ควรทำไหม', or 'worth it?'"
argument-hint: "The decision, trade-off, or problem to reason through"
metadata:
  author: phumin-k
  version: "1.0"
  scope: "**"
  tier: T1
  triggers:
    - "think about this"
    - "ควรทำไหม"
    - "worth it"
    - "trade-off"
    - "evaluate options"
    - "which approach"
    - "คิดให้ดี"
    - "reason through"
    - "เหตุผลคืออะไร"
---

# Senior Reasoning — Decision Quality Framework

> **"ดู consumer impact ไม่ใช่ดูแค่ internal cleanliness"**
> สัญญาณของ senior reasoning ที่ดี — ทุก decision ต้องพิสูจน์คุณค่าที่จุดที่ consumer สัมผัสได้ ไม่ใช่แค่ดูสวยข้างใน

## When to use this skill

- Facing 2+ options and need to choose the right one
- Evaluating whether a change/refactor/optimization is worth the cost
- Deciding how deep to investigate before acting
- Sensing that reasoning is circular or effort is disproportionate
- Making trade-offs between competing concerns (performance vs readability, DRY vs clarity)
- Any moment you catch yourself reasoning without citing evidence

## What this skill is NOT

- Not a design pattern guide → use `smart-design`
- Not a refactoring workflow → use `code-improvement`
- Not a self-correction circuit breaker → that's `anti-loop-debugging` (always-on)
- Not a post-session audit → use `agent-session-review`

This skill is about **how to think**, not what to build or how to build it.

---

## The 7 Reasoning Principles

### 1. Consumer Impact First

Every decision must prove value at the **consumer** level — not at the author level.

```
ASK: Who consumes this? (caller, user, reader, downstream system)
     Does the consumer experience improve?
     Can the consumer tell the difference?

GOOD reason:  "Callers no longer need to pass a dummy null argument"
GOOD reason:  "Reader can understand the flow in 1 pass instead of 3"
BAD reason:   "The internal structure is cleaner"
BAD reason:   "It follows the pattern better"
```

**Test:** If you removed the author from the room, would anyone notice the change was made? If no → it's internal cleanliness, not consumer value.

### 2. Challenge the Premise

Ask **"should we?"** before **"how?"**

```
BEFORE: "How should we refactor this method?"
FIRST:  "Should we refactor this method at all?"
        — Who consumes it? Is there a pain point?
        — Is the current code actually causing problems?
        — Would the effort be better spent elsewhere?
```

The most expensive mistake is executing a perfect implementation of something that shouldn't have been done. Catching "bad premise" early saves entire phases of work.

**Signals of unchallenged premise:**
- Implementing all candidates from an analysis without filtering
- Optimizing code that contributes <10% to the total bottleneck
- Refactoring for "consistency" when no consumer benefits

### 3. Evidence Over Speculation

Every decision must cite a **concrete artifact** — not intuition.

| Evidence type | Example | Strength |
|--------------|---------|----------|
| Code reference | "Line 85 calls this with null every time" | Strong |
| Test result | "Test failed with ORA-00001 on duplicate key" | Strong |
| Measurement | "DELETE takes 2,500ms; this optimization saves 140ms (5%)" | Strong |
| Pattern match | "3 other executors in this project do it this way" | Medium |
| Speculation | "This might cause issues" / "It could be slow" | Weak — find evidence |

**Rule:** If you write "I think", "probably", or "might" → pause. Find the artifact that confirms or denies. If 2 targeted searches produce no evidence → state the uncertainty explicitly instead of guessing.

### 4. Proportional Response

Match effort to problem magnitude. Don't architect a framework for a one-line fix.

```
Problem size       → Response size
─────────────────────────────────────────
Typo/naming        → Fix directly, no analysis
1 method, clear fix → Read + edit in 1 pass
Cross-file refactor → Plan 2-3 items, implement, verify
Architecture change → Design doc, user approval, phased rollout
```

**Quantification test:** Before committing to a complex approach, calculate:
- What % of the total problem does this address?
- How many files/callers are affected?
- Is there a simpler approach that gets 80% of the benefit?

If the answer reveals disproportionate effort → simplify or defer.

### 5. Kill Early, Commit Decisively

Reduce the option space **fast**. Don't carry 7 candidates through deep analysis.

```
Step 1: List candidates (quick — names only)
Step 2: Apply kill criteria BEFORE analysis:
        — Forces caller to pass dummy args? → KILL
        — Changes signature for aesthetics only? → KILL
        — Only 1 consumer? → KILL (no extraction value)
        — Requires multi-file reads just to prove value? → KILL
Step 3: Survivors (≤3) get real analysis
Step 4: Choose ONE → implement → verify
```

**After choosing:** Execute without re-survey. "Let me double-check my decision" is only justified when **genuinely new evidence** appears — not for comfort.

The `convergence-gate`: after analysis → **implement / defer / reject**. No fourth option.

### 6. Impact Ordering

When multiple changes are needed, sequence by **value ÷ risk**:

```
                  High Impact
                      │
         ┌────────────┼────────────┐
         │   DO FIRST  │  EVALUATE  │
    Low  │  (safe wins)│  (worth    │  High
    Risk ├────────────┼── risk?)───┤  Risk
         │   DO LATER  │  SKIP/DEFER│
         │  (low value)│  (not worth│
         └────────────┼──  risk)───┘
                      │
                  Low Impact
```

**Practical effect:** Do safe, high-impact changes first. Often, after safe changes are done, risky optimizations become obviously unnecessary — the problem has already shrunk enough.

### 7. Constraint as Design Filter

User constraints are **filters**, not afterthoughts. Apply them BEFORE exploration.

```
WRONG: Explore 20 files → analyze 7 candidates → "oh wait, user said 'useful only'" → discard 5
RIGHT: User said "useful only" → only look at files with known consumer pain → 2 candidates → implement
```

Every explicit user constraint (scope, style, "don't over-engineer", "useful only") shrinks the search space. Apply it at step 0, not step 5.

---

## Decision Framework (use when facing a choice)

When you need to choose between approaches, run this:

```
┌─────────────────────────────────────────────────────┐
│ 1. WHAT are the options? (name them — ≤3)           │
│ 2. WHO is the consumer? (caller, user, reader)      │
│ 3. WHAT evidence supports each option?              │
│    (cite file, line, measurement — not speculation)  │
│ 4. WHAT is the cost of each? (files touched,        │
│    risk of breaking, complexity added)               │
│ 5. Does the highest-value option pass the           │
│    proportionality test? (effort ∝ impact)           │
│                                                      │
│ → CHOOSE the option with best evidence + consumer    │
│   impact at proportional cost.                       │
│ → If no option clears the bar → DEFER or REJECT.    │
│ → Once chosen → COMMIT. No re-survey without         │
│   new evidence.                                      │
└─────────────────────────────────────────────────────┘
```

## Common Decision Patterns

### "Should we refactor X?"
1. Who consumes X? List callers.
2. What's the consumer pain? (confusing API? duplicate args? fragile coupling?)
3. Does the proposed change reduce consumer pain — or just author pain?
4. If consumer pain is real → refactor. If only author pain → leave it.

### "Should we optimize Y?"
1. Measure Y's contribution to the total bottleneck (%, not "feels slow").
2. If Y < 10% of total → the complexity isn't worth it.
3. If Y > 30% of total → quantify the expected gain before implementing.
4. After implementing → measure again. Hope is not a metric.

### "How deep should we investigate?"
1. Can you answer WHAT file + WHAT change + WHY in 1 sentence each?
2. YES → stop investigating, start implementing.
3. NO → make 1 targeted search to fill the specific gap. Re-check.
4. Still NO after 2 searches → you're missing domain knowledge, not file knowledge. Ask the user.

### "Should we delegate this?"
1. What do you already know? (files, methods, rationale)
2. What specifically are you missing?
3. Could you get it in ≤3 tool calls?
4. YES to #3 → do it yourself. Delegation costs more than 3 calls.

---

## Anti-Patterns This Skill Prevents

| Anti-pattern | What happens | Senior reasoning says |
|-------------|-------------|----------------------|
| Internal cleanliness refactor | Code looks tidier but no consumer benefits | Challenge the premise — who benefits? |
| Analysis paralysis | 7 candidates analyzed in depth, 5 discarded | Kill early — apply criteria before analysis |
| Speculative generalization | "What if there are many X?" without evidence | Evidence first — verify the invariant |
| Disproportionate optimization | 2 hours optimizing a 5% bottleneck | Quantify — is 5% worth the complexity? |
| Comfort re-survey | "Let me check one more time" after deciding | Commit — new evidence only, not comfort |
| Post-hoc constraint application | Explore everything, then apply user limits | Constraint-first — filter before exploring |
| Effort-anchored justification | "We already spent time on this, so let's finish" | Sunk cost — re-evaluate with current evidence |

---

## Integration with Other Skills

- **Before `code-improvement`**: Run Principle 1 (consumer impact) and Principle 2 (challenge premise) to filter candidates
- **Before `plan-to-implementation`**: Run Principle 6 (impact ordering) to sequence the plan
- **During any skill**: If reasoning feels circular → Principle 5 (kill early, commit decisively)
- **After `smart-design`**: Run Principle 4 (proportional response) to check if the design is right-sized
