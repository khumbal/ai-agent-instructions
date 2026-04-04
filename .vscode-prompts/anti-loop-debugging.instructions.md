---
name: "Anti-Loop & Self-Correction"
description: 'Decision-making principles for debugging, error recovery, and cognitive self-correction. Loaded when encountering errors, failed approaches, over-analysis, unjustified delegation, or fuzzy reasoning during work.'
---

# Debugging & Error Recovery

When something fails, pause and reason before reacting.

1. **Understand first**: Read the full error, stack trace, and surrounding context. Diagnose the root cause — not the symptom. Log the failed approach in session memory for reference.

2. **Fix with intent**: Make a single, well-reasoned fix addressing the root cause. If it doesn't work, the diagnosis was probably wrong — re-analyze with this new evidence.

3. **Adapt on failure**: Same approach fails twice → it's the wrong approach. Step back, question your assumptions, and choose a fundamentally different strategy. Don't iterate on a broken idea.

4. **Verify proportionally**: After every edit, run `get_errors` (type check — instant, free). Lint after a logical unit. Run tests only after completing a feature or before declaring "done". Never test mid-implementation on unfinished code — it generates false failures that waste tokens to diagnose.

5. **Revert on cascade**: Edit breaks compilation in ≥2 files → revert and re-analyze. Stop the bleeding before continuing.

6. **Escalate when appropriate**: Security-sensitive changes (auth, crypto, secrets), destructive schema changes, or ambiguous high-impact requirements → ask the user before proceeding.

---

# Cognitive Self-Correction

**Auto-trigger**: Check these when the conversation is long (≥5 turns on one task), when you're about to delegate, or when you notice yourself reading/searching without producing output.

## Over-Analysis Detection

**Symptom**: Multiple reads/searches without converging on a concrete action.

Self-check — can you answer all three?
1. **WHAT** file am I changing?
2. **WHAT** is the change? (describe in 1 sentence)
3. **WHY** is this the right approach? (cite evidence from code, not speculation)

If you can answer all three → **stop analyzing, start implementing.**
If you can't answer even one → you lack information. Make ONE targeted search to fill that gap, then re-check.

Re-surveying "for confidence" when you already have WHAT+WHAT+WHY = waste. Commit and verify instead.

## Delegation Cost Check

**Symptom**: About to launch @Explore or @Implement but can't articulate what you DON'T know.

Before every delegation, answer:
- **What do I already know?** (files, methods, rationale from summary or prior turns)
- **What specifically am I missing?** (name it — not "understand the codebase")
- **Could I get it in ≤3 tool calls?** (grep + read ±20 lines + edit)

If the answer to the third question is YES → do it yourself. Delegation costs more than 3 tool calls.

**Context already rich?** When the conversation summary or prior turns contain file paths + method names + rationale + constraints → you have enough to act. Don't re-explore.

## Fuzzy Reasoning Detection

**Symptom**: You catch yourself writing "might", "probably", "could be", "let me check more" without pointing to specific code.

Rules:
- Every decision must cite a concrete artifact: file path, line number, method name, error message, or test result.
- "I think X is the right approach" without evidence → pause and find the evidence first.
- If you can't find evidence after 2 targeted searches → state the uncertainty to the user instead of guessing.

## Progress Stall Detection

**Symptom**: ≥3 consecutive tool calls that don't produce an edit or a clear answer.

Self-check:
- Am I reading files I've already read?
- Am I searching for something I could infer from what I already know?
- Am I avoiding a decision because I'm not 100% sure?

If any is YES → make a decision with current evidence and course-correct if needed. 80% confidence with verification is better than 95% confidence from 20 more reads.
