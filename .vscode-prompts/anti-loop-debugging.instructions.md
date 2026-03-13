---
description: 'Decision-making principles for debugging and error recovery. Loaded when encountering errors, failed approaches, or needing to diagnose issues.'
---

# Debugging & Error Recovery

When something fails, pause and reason before reacting.

1. **Understand first**: Read the full error, stack trace, and surrounding context. Diagnose the root cause — not the symptom. Log the failed approach in session memory for reference.

2. **Fix with intent**: Make a single, well-reasoned fix addressing the root cause. If it doesn't work, the diagnosis was probably wrong — re-analyze with this new evidence.

3. **Adapt on failure**: Same approach fails twice → it's the wrong approach. Step back, question your assumptions, and choose a fundamentally different strategy. Don't iterate on a broken idea.

4. **Verify after every edit**: Type-check, re-read changed code, verify logic. Run tests if they exist. Never assume correctness — confirm it.

5. **Revert on cascade**: Edit breaks compilation in ≥2 files → revert and re-analyze. Stop the bleeding before continuing.

6. **Escalate when appropriate**: Security-sensitive changes (auth, crypto, secrets), destructive schema changes, or ambiguous high-impact requirements → ask the user before proceeding.
