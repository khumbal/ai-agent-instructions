---
name: codebase-wiring-audit
description: "Verifies architectural wiring — confirms that implemented components are actually connected in the runtime execution path, not just built in isolation. Produces a wiring verdict map (wired/disconnected/orphaned) with exact file:line evidence. Use when auditing after feature implementation, verifying design doc claims against actual code, conducting integration readiness checks, or when the user says 'audit wiring', 'verify integration', 'ตรวจ wiring', 'check connections', 'is X actually called'."
argument-hint: "The feature area, design doc, or specific module connections to audit"
metadata:
  author: phumin-k
  version: "1.0"
  scope: "**"
  tier: T1
  triggers:
    - "audit wiring"
    - "verify integration"
    - "check connections"
    - "is it actually called"
    - "ตรวจ wiring"
    - "integration audit"
    - "architectural audit"
    - "verify implementation"
    - "check pipeline"
    - "wired correctly"
---

# Codebase Wiring Audit

> **Purpose**: Verify that architectural components are actually connected at runtime — not just implemented in isolation. The most dangerous bugs are orphaned functions: fully coded, fully tested in unit tests, but never called from the integration path.

## When to use this skill

- After implementing features from a design doc or proposal
- Before declaring an implementation wave "complete"
- When auditing whether what's documented is what's integrated
- When a user asks "is X actually wired up?" or "does A call B?"
- Integration readiness check before E2E testing

## Audit Philosophy

**grep is truth, subagents lie.** Subagents (Explore) can misidentify existing code as "not implemented" by finding pseudocode in design docs instead of searching actual source files. The session that created this skill lost an entire turn to Explore reporting `challengeWisdom()` as "only pseudocode in proposal" when it was fully implemented with tests in `src/memory/consolidation.ts`.

**Three states, not two.** Code isn't just "implemented" or "not implemented":
- **Wired** ✅ — implemented AND called from the integration path
- **Orphaned** ❌ — implemented and tested but NEVER called from integration path
- **Missing** ⬚ — not implemented at all

Orphaned code is the sneakiest category — unit tests pass, type-check passes, but the feature doesn't work at runtime.

---

## Audit Procedure

### Step 1: Gather Claims

Identify what the design doc/proposal claims should exist. Each claim is a **connection**, not a function:

```
BAD claim:  "encodeEpisode() exists"          (tests implementation, not wiring)
GOOD claim: "Gateway Phase 5 calls encodeEpisode()" (tests connection)
```

Format each claim as: `[Source] → calls/uses → [Target]`

Example claims from a memory system:
```
1. Gateway Phase 5 → calls → encodeEpisode() → saves via store.saveEpisode()
2. Dispatcher → calls → recallRelevant() → injects into ContextSlice
3. serializeSlice() → wraps recalledLessons → in XML tags
4. Gateway → calls → challengeWisdom() → on quality gate exhaustion
```

### Step 2: Verify Each Claim (Direct Evidence)

For EACH claim, verify with this exact sequence:

```
1. grep function/method name in TARGET file → confirm it exists (file:line)
2. grep function/method name in SOURCE file → confirm it's called (file:line)
3. Read ±20 lines around the call site → confirm:
   - Arguments passed correctly
   - Return value used (not ignored)
   - Error handling present (try/catch if non-critical)
   - Called in the right phase/order (not too early/late)
```

**CRITICAL RULE**: Do NOT accept Explore subagent claims of "not found" or "not implemented" as evidence. When an Explore returns "doesn't exist", ALWAYS verify with direct `grep` in the source directory before recording as Missing.

Why: Explore agents search broadly and may find references in design docs, proposals, or comments — then incorrectly conclude "only pseudocode". Grep in `src/` is definitive.

### Step 3: Classify Each Finding

| Verdict | Criteria | Action |
|---------|----------|--------|
| ✅ Wired | grep confirms: target exists AND source calls it AND args correct | Document, no fix needed |
| ❌ Orphaned | grep confirms: target exists BUT source never calls it | Fix: add the call at correct integration point |
| ⚠️ Partial | target called but with wrong args, missing error handling, or wrong location | Fix: correct the call site |
| ⬚ Missing | grep confirms: target doesn't exist in source files | Report as unimplemented |

### Step 4: Produce Wiring Map

Output format:
```markdown
## Wiring Audit: [Feature/Module Name]

### Connection Map
| # | Connection | Source → Target | Verdict | Evidence |
|---|-----------|----------------|---------|----------|
| 1 | Episode encoding | gateway.ts:L975 → encodeEpisode() | ❌ Orphaned | grep: 0 calls in gateway.ts |
| 2 | Memory recall | dispatcher.ts:L564 → recallRelevant() | ✅ Wired | Called with (task, role, store, 3) |
| 3 | XML isolation | serializeSlice():L189 → `<prior_lessons>` | ⚠️ Partial | Plain text, no XML wrapper |

### Disconnections (Actionable)
1. **[Connection name]** — [Source] never calls [Target]
   - Fix: Add call at [exact location] with [expected args]
   - Risk: [What breaks without this connection]

### Quality Issues (Report Only)
- [Issues that aren't connection bugs — perf, dead code, missing barrel]
```

---

## Common Pitfalls (from real sessions)

### Pitfall 1: Subagent False Negatives
**What happened**: Explore agent reported `challengeWisdom()` as "only pseudocode in proposal doc" and `consolidate()` as "not existing". Both were fully implemented with unit tests.
**Prevention**: Step 2's grep verification. Never trust "doesn't exist" without `grep -r "functionName" src/`.

### Pitfall 2: Unit Tests Masking Orphaned Code
**What happened**: `encodeEpisode()` had 12 passing unit tests. But it was never called from `gateway.ts`. The feature "worked" in tests but not at runtime.
**Detection**: After confirming a function exists (Step 2.1), always check the SOURCE (Step 2.2). Existing unit tests ≠ wired integration.

### Pitfall 3: Confusing "Implemented" with "Wired"
**What happened**: Audit reported 7 items as "wired correctly" but 2 were actually orphaned. The function body existed and was correct, but the call site was missing.
**Prevention**: Always verify the connection (source→target), not just the target.

---

## Integration with Other Skills

- **After audit → plan-to-implementation**: Disconnections become fix items with exact file:line
- **After fix → code-review**: Verify the wiring fix didn't break existing callers
- **After fix → create integration test**: Prove the connection works end-to-end

## Verification After Fixes

After fixing disconnections:
1. `tsc --noEmit` (or equivalent type-check) — 0 errors
2. Run existing unit tests for affected modules — 0 regressions
3. Write integration test that exercises the full connection path
4. Run integration test — passes

---

## Rules

- **Evidence-based verdicts only** — every ✅ or ❌ must cite file:line from actual grep/read
- **Grep before Explore** — for existence verification, grep is faster and more reliable
- **Test both ends** — a wired connection means source calls target AND target exists
- **Separate bugs from opinions** — disconnected wires are bugs; design preferences are not
- **Don't fix during audit** — audit produces the map, separate implementation phase fixes it
- **Update stale memory** — if audit corrects prior findings, update repo memory immediately
