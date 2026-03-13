---
name: java-expert-review
description: "Advanced Java code review with deep JVM, memory, CPU, and Spring Boot expertise. Covers GC pressure, memory leaks, thread contention, JIT-hostile patterns, Spring proxy pitfalls, and production performance anti-patterns. Use for thorough Java performance and architecture review."
argument-hint: "The Java files or feature to review for performance and architecture issues"
metadata:
  author: phumin-k
  version: "3.1"
  scope: "**/*.java"
  tier: T1
  triggers:
    - "GC pressure"
    - "memory leak"
    - "concurrency"
    - "performance review"
    - "JVM"
    - "thread safety"
---

# Java Expert Review

## When to use this skill

Complete expert-level Java code review: foundational quality (correctness, exception handling, readability, security) through advanced concerns (JVM internals, memory/GC, CPU, thread safety, Spring Boot architecture, production performance).

## Review Philosophy

**Complete expert-level code review** covering both foundational quality and advanced JVM-level concerns. Prioritize by production impact — correctness and security first, then performance, then maintainability. Do not skip foundational checks just because advanced analysis is also requested.

Security still matters: for Java services and internal/admin endpoints, review authorization boundaries, sensitive logging, SQL construction, unsafe deserialization, and privilege-boundary mistakes.

OOP and design patterns are review tools, not review goals. Recommend them only when they solve a concrete problem in the current code. Do not penalize simple code for not using patterns.

### Reporting Rules
1. **Show the code** — every finding MUST include the problematic code snippet AND a **minimal, targeted diff** fix snippet (only changed lines ±3 lines context; NEVER full class rewrites)
2. **Explain the failure scenario** — describe HOW it fails in production (e.g., "ถ้ามี 2 request พร้อมกัน thread A restore fetchSize ขณะ thread B กำลังใช้งาน")
3. **Quantify impact** — numbers beat adjectives ("HashMap resize 16→32→64→128 = 3 array copies" > "bad initial capacity")
4. **Anti-hallucination** — only use numbers grounded in JVM specs, Javadoc, or source code constants. NEVER invent memory byte sizes, GC timings, or Big-O complexities you cannot justify. When uncertain, describe qualitatively.
5. **Trace callers** — for any modified public method, check usages to assess regression blast radius. Report in a dedicated `Blast radius:` field: `N callers in M files would be affected.`
6. **State confidence** — every reported finding must include `Confidence: high` or `Confidence: medium`. Do not report low-confidence findings.
7. **De-duplicate root causes** — when multiple files show the same underlying defect and same remediation, report one primary finding and list affected locations.

## Multi-Pass Deep Analysis

### Pass 1: Memory & GC Pressure

**Heap allocation hotspots:**
- Unnecessary object creation in loops (autoboxing `int→Integer`, `String.format` in hot paths)
- `String` concatenation in loops → use `StringBuilder` (or `StringJoiner` for delimited)
- Lambda/method-reference creating new objects per invocation in hot paths
- `Stream.collect()` intermediate collections when result is discarded
- Large `byte[]`/`char[]` allocations that could use pooling or streaming

**Collection sizing:**
- `new ArrayList<>()` / `new HashMap<>()` without initial capacity when size is known or estimable → causes array-copy resize cascading
- `HashMap` load factor misunderstanding → capacity should be `expectedSize / 0.75 + 1`
- Using `LinkedList` when `ArrayList` is faster for all but head-insert workloads
- `ConcurrentHashMap` vs `Collections.synchronizedMap` choice

**Memory leaks:**
- Unclosed `InputStream`, `OutputStream`, `Connection`, `ResultSet`, `Statement` — even with try-with-resources, check nested resources
- `ThreadLocal` not removed after use → classloader leak in web containers
- Listeners/callbacks registered but never deregistered
- Static collections growing unbounded (caches without eviction)
- Inner class holding implicit reference to outer class preventing GC
- `SoftReference` / `WeakReference` misuse

**GC-unfriendly patterns:**
- Large objects (>50% TLAB, >8KB default) triggering direct allocation / humongous allocation (G1)
- Frequent young→old promotion (objects surviving too many GC cycles)
- Finalize methods (deprecated since Java 9, always avoid)
- Phantom reference misuse

### Pass 2: CPU & Thread Efficiency

**CPU hotspot patterns:**
- Regex `Pattern.compile()` inside method body → hoist to `static final`
- `synchronized` on hot path when `volatile` / `AtomicReference` / lock-free suffices
- `Collections.sort()` on every access instead of maintaining sorted structure
- Redundant computation inside loop body (invariant not hoisted)
- `Class.forName()`, `Method.invoke()` reflection in tight loops → cache `MethodHandle`

**Thread contention:**
- **Mutating shared singleton bean state** — e.g., `JdbcTemplate.setFetchSize()` on a shared bean affects ALL threads; use `PreparedStatementCreator` for statement-level config or create a dedicated instance
- **`HashMap.computeIfAbsent()` in concurrent context** → Java 8 can infinite loop, Java 9+ can corrupt; use `ConcurrentHashMap` for any static/shared map with lazy population
- `synchronized(this)` or `synchronized(String)` → use private lock object
- Lock ordering inconsistency → deadlock risk (A→B vs B→A)
- `wait()` without `while` loop guard → spurious wakeup vulnerability
- Thread pool sizing: CPU-bound = nCPU, IO-bound = nCPU × (1 + W/C ratio)
- `ExecutorService` not shut down → thread leak
- `CompletableFuture` default pool (ForkJoinPool.commonPool) not appropriate for blocking I/O
- `@Async` without custom executor → shared pool contention

**JIT-hostile patterns (prevent inlining/optimization):**
- Methods > 325 bytecodes (HotSpot inlining threshold) in hot paths
- Excessive polymorphic dispatch (>2 implementations) on hot-path interface calls → megamorphic callsite
- Exception-based flow control (try/catch for normal flow) → prevents JIT optimization of the entire block
- Unpredictable branches in tight loops → branch prediction miss

### Pass 3: Spring Boot & Framework Specifics

**Context-awareness:** If the code under review does NOT use standard Spring DI (e.g., batch executors that create their own `AnnotationConfigApplicationContext`, plain POJOs, or utility classes), state which Spring concerns do not apply (proxy/AOP, bean lifecycle, `@Transactional` propagation) and focus only on the concerns that DO apply (JdbcTemplate usage, connection handling, transaction management via programmatic API).

**Bean lifecycle pitfalls:**
- `@PostConstruct` doing heavy I/O → slows application startup
- `@Scope("prototype")` injected into singleton → always returns same instance (use `ObjectProvider<T>` or `Provider<T>`)
- `@Lazy` not taking effect because something eagerly references the bean
- Missing `@DependsOn` for order-sensitive initialization

**Proxy & AOP pitfalls:**
- `@Transactional` on private method → proxy ignores it (no AOP interception)
- Self-invocation (`this.method()`) bypasses proxy → `@Cacheable`, `@Async`, `@Transactional` annotation ignored
- CGLIB proxy on final class/method → fails silently or throws
- `@Transactional(readOnly = true)` not set on read-only operations → misses Hibernate flush optimization

**Connection & Transaction:**
- Connection pool exhaustion: holding connection across long operations (REST call inside `@Transactional`)
- Transaction scope too broad → locks held too long → contention
- Missing `@Transactional` rollback for checked exceptions (`rollbackFor = Exception.class`)
- Nested `@Transactional` propagation confusion (REQUIRED vs REQUIRES_NEW)
- JDBC fetch size not set for large result sets → OOM or excessive round-trips

**JdbcTemplate specifics (relevant to batch systems):**
- `queryForList()` loading entire result set into memory → use `query(RowCallbackHandler)` for streaming
- Missing `setFetchSize()` for large queries → Oracle defaults to 10 rows per round-trip
- Batch insert without `batchUpdate()` → N round-trips instead of 1
- `@Transactional` wrapping individual row operations instead of batch → N commits instead of 1
- **`setFetchSize()` on shared JdbcTemplate bean** → mutates singleton state, not thread-safe; use `PreparedStatementCreator` to set per-statement

**Web request thread anti-patterns:**
- **Synchronous long-running batch in HTTP handler** — `Thread.sleep()` or processing thousands of records in request thread → timeout, thread pool exhaustion
- No async job pattern for heavy operations (should return job ID + poll status)
- Missing timeout documentation for long-running endpoints

**HTTP client & network patterns:**
- Missing connect/read/write timeouts on `HttpClient`, `RestTemplate`, or `WebClient` → thread hangs indefinitely on unresponsive downstream
- No retry with exponential backoff for transient failures (5xx, connection reset) → cascade failure to upstream callers
- TLS certificate validation disabled (`SSLContext` trust-all) left in production code
- Hardcoded URLs/ports/hosts without externalized configuration → deployment inflexibility
- Missing circuit breaker or bulkhead for external service calls in high-throughput paths
- **N+1 query pattern** — query-per-record in a loop (JPA lazy loading, or manual `SELECT ... WHERE id = ?` inside `for`) instead of batch `IN (...)` or `JOIN`

### Pass 4: Architecture & Design

**Correctness & code quality (foundational):**
- Logic errors: inverted conditions (`!` misplaced), wrong boolean operators (`&&` vs `||`), missing edge cases (null, empty collection, zero, negative, boundary values)
- Null safety: NPE risks on unguarded dereference chains (`a.getB().getC()`), `Optional` misuse (`optional.get()` without `isPresent()`), returning null where caller expects non-null
- Resource management: unclosed `InputStream`, `Connection`, `Statement`, `ResultSet` outside try-with-resources — even when inner resource is managed, check if outer wrapper leaks
- Dead code: unreachable branches after unconditional return/throw, unused private methods, commented-out code blocks that should be deleted (Git preserves history)
- Misleading identifiers: method/variable names that contradict actual behavior (e.g., `isValid()` that also mutates state, `getUser()` that creates a new user) — **only flag when naming actively causes misunderstanding**, not style preference
- Magic numbers/strings: unexplained literals in business logic that harm understanding (e.g., `if (status == 3)` instead of named constant) — **not in test code**
- Type safety: unchecked casts (`(List<String>) rawList`), raw generic types, unsafe array covariance
- API contracts: inconsistent return types across similar methods (some return null, some empty, some Optional), missing input validation at public API / service boundaries

**SOLID violations with runtime impact:**
- God class (>500 lines, >5 responsibilities) → hard to test, slow to compile, high coupling
- Service calling another service's repository directly → bypasses business rules
- Circular dependencies → Spring context creation failure or proxy hell
- Leaky abstractions (returning JPA entity from controller, SQL exception propagating to API)

**OOP & design-pattern fit (pragmatic, not dogmatic):**
- Check responsibility and cohesion: does the class have one clear reason to change?
- Prefer **composition over inheritance** unless inheritance expresses a stable domain relationship and reduces duplication cleanly
- Flag inheritance misuse when subclasses only toggle small behavior differences or depend on parent internals
- Suggest interfaces/abstractions only when there is a real need: multiple implementations, test seams, or unstable behavior branches
- Common examples of when patterns are justified (not an exhaustive list):
  - **Strategy** for 3+ behaviors that evolve independently, replacing large conditionals
  - **Builder/Factory** when constructors/setters already harm readability or correctness
  - **Facade/Adapter** to isolate cross-system integration complexity and external change
  - **Template Method / Pipeline / Chain** for stable multi-step flows where individual steps vary
  - Other patterns (Observer, Decorator, State, Command, etc.) when the same justification bar is met
- Do **not** recommend patterns for tiny utilities, simple CRUD, or one-off flows where plain code is clearer
- Pattern overuse is also a finding: extra indirection, too many files, single-implementation interfaces, and abstraction without a consumer problem

**Error handling:**
- Catching `Exception` / `Throwable` broadly → masks bugs (acceptable in top-level batch orchestrators, not in service methods)
- Empty catch blocks → silent failure
- Rethrowing without cause → lost stack trace (`throw new RuntimeException(msg)` vs `throw new RuntimeException(msg, e)`)
- `@ControllerAdvice` missing → inconsistent error responses
- Exception type hierarchy misuse: catching broad type then `instanceof` checking — use specific catch blocks
- Checked exceptions leaking across architectural boundaries (e.g., `SQLException` thrown from service layer to controller)
- Error message quality: generic "Error occurred" without context (which record? which field? what was the input?) hampers production debugging
- Inconsistent error propagation: some methods throw, some return null, some return error codes — within the same layer

**Security & trust boundaries:**
- Missing authorization/role checks on internal or administrative endpoints
- Sensitive data logged in plaintext (PII, tokens, credentials, full payloads)
- SQL built via concatenation or partial parameterization (includes JPQL, native queries, Criteria string building)
- Unsafe deserialization / object mapping of untrusted input
- Assuming network path or URL prefix alone is sufficient protection
- **Hardcoded secrets**: API keys, passwords, tokens, or encryption keys in source code (check `String` literals, `@Value` defaults, properties files in scope)
- **Cryptographic misuse**: MD5/SHA1 used for security purposes, `java.util.Random` for security-sensitive operations (use `SecureRandom`), hardcoded IVs/salts, deprecated crypto APIs
- **Dependency risk**: if `pom.xml`/`build.gradle` is in scope, flag obviously outdated dependencies with known critical CVEs (e.g., Log4j <2.17, Jackson <2.13, Spring4Shell-era Spring) — do NOT hallucinate CVE numbers, only flag versions you are confident about

**Mixed-artifact review:**
- SQL, YAML, properties, and XML that directly change Java runtime behavior, security, or data handling should be reviewed as part of the same finding set
- Generated files or passive config should be mentioned only if they materially affect runtime behavior

**Concurrency design:**
- Shared mutable state without synchronization
- Date/time formatters (`SimpleDateFormat`, `DateTimeFormatter` that's mutable) shared across threads
- Non-thread-safe collections used in concurrent context (`HashMap` in multi-threaded code)

**Correctness patterns (subtle bugs):**
- **Reference equality** (`==`/`!=`) on objects for change detection — works by accident when method returns same reference, breaks when refactored to return new String (e.g., via `String.valueOf()`)
- **Batch/pagination boundary logic** — `maxRecords` check outside processing loop → off-by-batch (e.g., maxRecords=5 but batchSize=500 → processes 500 before stopping); check must be inside loop or batch size capped to `Math.min(batchSize, remaining)`
- **java.time API misuse** — `'Z'` as literal char in `DateTimeFormatter.ofPattern()` instead of `XXX`/`X` for actual timezone offset; `LocalDateTime` used where `ZonedDateTime`/`Instant` is needed
- **Off-by-one in substring/index** — `substring(m.start())` vs `substring(m.start(), m.end())`, hardcoded leading/trailing chars that assume specific input format

### Pass 5: Verification (CRITICAL)

For EVERY finding from Pass 1-4:
1. **Re-read actual code line** — confirm issue exists at that exact location
2. **Check surrounding context** — maybe the code already handles it (e.g., try-with-resources wrapping)
3. **Check Java version** — some issues are version-specific (e.g., String concat optimized since Java 9+)
4. **Check framework version** — Spring Boot version may have different behavior
5. **Estimate impact** — high-frequency path? Or one-time startup? Don't flag cold-path micro-optimizations.
6. **If uncertain → demote or drop.** Zero false positives > catching everything.

## Severity Levels

| Icon | Level | Meaning |
|------|-------|---------|
| 🔴 | Critical | Will cause OOM, deadlock, data corruption, security vulnerability, or correctness bug in production |
| 🟡 | Warning | Performance degradation under load, latent concurrency bug, or error handling gap |
| 🟢 | Nit | Optimization opportunity, readability improvement, or minor best practice |
| 🔵 | Architecture | Structural concern affecting maintainability, scalability, or design quality |
| 🟣 | Pre-existing | Issue not introduced by current change |

## Impact Annotation

Every finding MUST include estimated impact:

```
- **[file:L##]** Issue → Fix | Impact: [high/medium/low] @ [hot-path/cold-path/startup]
```

- **hot-path**: Called per-request or per-record in batch processing
- **cold-path**: Called once per batch run or during initialization
- **startup**: Only during application bootstrap

## Output Format

```
## Expert Review: [feature/branch → target]

### Overview
Module: [module name]
Files: N files (+N lines / -N lines)
[2-3 sentence overall assessment — architecture quality, test coverage, safety mechanisms]
[If review coverage was partial, say so explicitly: `Partial review only — N files deeply reviewed, M lightly scanned`]

### Environment
- Java version: [detected or assumed]
- Spring Boot version: [detected or assumed]
- Context: [batch/web/reactive]

### 🔴 Critical (Production Risk)
N. **[Short title]**
File: [file name]
[Problematic code snippet]

Problem: [Explain the failure scenario — HOW it fails, not just WHAT is wrong]
Fix: [Concrete code showing the solution]
Blast radius: [N callers in M files / No downstream callers found / Not applicable]
Confidence: [high/medium]
| Impact: high @ hot-path

### 🟡 Warning (Performance/Concurrency)
N. **[Short title]**
File: [file name]
[Same format: code → problem → fix → blast radius → confidence → impact]

### 🔵 Architecture
N. **[Short title]**
File: [file name]
Concern → Recommendation: **Required** | **Optional**

Every architecture finding MUST end with one of these labels:
- `Recommendation: **Required**` — current design is causing correctness/maintainability risk now
- `Recommendation: **Optional**` — improvement opportunity, but current design is acceptable for current scope
This applies to ALL architecture findings (structural, OOP/design, and operational), not just OOP.

### 🟢 Nit (Optimization)
N. **[Short title]**
File: [file name]
Suggestion | Impact: low @ cold-path

### 🟣 Pre-existing
- **[file:L##]** Issue

### 🔒 Security
[If security pass found issues, list them here with same format as other findings]
[If no issues: `No SQL injection, PII logging, authorization, or deserialization concerns identified in reviewed scope.`]

### ✅ Positive Findings (สิ่งที่ทำได้ดี)
- [What's done well — good patterns, safety mechanisms, test coverage, etc.]

### 📊 Summary
| Level | Count | Key Issues |
|-------|-------|------------|
| 🔴 Critical | N | [list] |
| 🟡 Warning | N | [list] |
| 🔵 Architecture | N | [list] |
| 🟢 Nit | N | [list] |

Build validation: [Verified from available diagnostics / Not verified]
Merge recommendation: [BLOCK — must fix N critical issues before merge / PASS with warnings / PASS with limited coverage / Needs deeper review]
```

## Example Output

Use this as a style reference. Keep the same level of specificity, but adapt the content to the actual code under review.

```markdown
## Expert Review: fix/audit-report-masking-data -> release/10.0.0

### Overview
Module: s1_api_report
Files: 12 files (+3002 lines / -0 lines)
Overall structure is strong: layering is clear, tests exist, and safety mechanisms such as dry-run and preview mode reduce blast radius. The main remaining risk is thread-safety and operational behavior under concurrent execution.

### Environment
- Java version: 17 (detected)
- Spring Boot version: 3.2.x (detected)
- Context: web + batch-like maintenance endpoint

### 🔴 Critical (Production Risk)
1. **Shared JdbcTemplate state mutation is not thread-safe**
File: LogAuditMaskingServiceImpl.java
```java
int originalFetchSize = jdbcTemplate.getFetchSize();
jdbcTemplate.setFetchSize(JDBC_FETCH_SIZE);
try {
  return jdbcTemplate.query(selectSql, extractor, cutoffDate);
} finally {
  jdbcTemplate.setFetchSize(originalFetchSize);
}
```

Problem: If two requests execute concurrently, thread A can restore the fetch size while thread B is still using the shared singleton `JdbcTemplate`. That creates cross-request interference and non-deterministic query behavior for unrelated callers using the same bean.
Fix:
```diff
- int originalFetchSize = jdbcTemplate.getFetchSize();
- jdbcTemplate.setFetchSize(JDBC_FETCH_SIZE);
- try {
-     return jdbcTemplate.query(selectSql, extractor, cutoffDate);
- } finally {
-     jdbcTemplate.setFetchSize(originalFetchSize);
- }
+ return jdbcTemplate.query(con -> {
+     PreparedStatement ps = con.prepareStatement(selectSql);
+     ps.setFetchSize(JDBC_FETCH_SIZE);
+     ps.setObject(1, cutoffDate);
+     return ps;
+ }, extractor);
```
Blast radius: 3 callers in 2 files would be affected.
Confidence: high
| Impact: high @ hot-path

### 🟡 Warning (Performance/Concurrency)
1. **Max-record limit is enforced too late**
File: LogAuditMaskingServiceImpl.java
```java
for (AuditRecord record : batch) {
  process(record);
  totalProcessed++;
}

if (request.getMaxRecords() != null && totalProcessed >= request.getMaxRecords()) {
  hasMore = false;
}
```

Problem: With `maxRecords=5` and `batchSize=500`, the first loop still processes 500 rows before the stop condition is checked. The endpoint appears to support capped execution but exceeds the contract by up to one full batch.
Fix:
```diff
 for (AuditRecord record : batch) {
+    if (request.getMaxRecords() != null && totalProcessed >= request.getMaxRecords()) {
+        hasMore = false;
+        break;
+    }
   process(record);
   totalProcessed++;
 }
```
Blast radius: No downstream callers found.
Confidence: high
| Impact: medium @ hot-path

### 🔵 Architecture
1. **Long-running maintenance work is executed on the request thread**
File: LogAuditMaskingServiceImpl.java
Concern: The operation behaves like a batch job but is executed synchronously in an HTTP request path. That increases timeout and thread-pool exhaustion risk.
Recommendation: Return a job ID and move execution to an async worker, or document a strict operational timeout boundary.

### ✅ Positive Findings (สิ่งที่ทำได้ดี)
- Dry-run default and preview mode reduce operational blast radius.
- Infinite-loop guard shows good defensive thinking for maintenance tooling.
- Tests cover important masking paths instead of only happy-path API behavior.

### 📊 Summary
| Level | Count | Key Issues |
|-------|-------|------------|
| 🔴 Critical | 1 | Shared JdbcTemplate state mutation |
| 🟡 Warning | 1 | Off-by-batch max-record enforcement |
| 🔵 Architecture | 1 | Long-running work on request thread |
| 🟢 Nit | 0 | - |

Build validation: Not verified
Merge recommendation: BLOCK — must fix 1 critical issue before merge
```

### Optional OOP / Design Example

Use this style when the current design is acceptable, but there is a worthwhile design improvement if complexity grows. The tone should be helpful, not prescriptive.

```markdown
### 🔵 Architecture
2. **Conditional dispatch may become a Strategy candidate if behaviors continue to grow**
File: CustomerSyncService.java
```java
if (sourceType.equals("EBAN")) {
  return syncFromEban(batchDate, records);
} else if (sourceType.equals("CIS")) {
  return syncFromCis(batchDate, records);
} else if (sourceType.equals("MANUAL")) {
  return syncFromManual(batchDate, records);
}
throw new IllegalArgumentException("Unsupported sourceType: " + sourceType);
```

Concern: The current implementation is still readable and acceptable for three cases, so this is **not** a required refactor. However, if more source types or source-specific pre/post-processing rules are expected, this conditional block will become harder to extend and test without touching the same method repeatedly.
Recommendation: **Optional** — keep the current form for now unless new modes are already planned. If this area starts growing, consider a small `Strategy` extraction such as `Map<String, SyncStrategy>` to isolate source-specific behavior without changing the orchestration flow.
Blast radius: Not applicable
Confidence: high
| Impact: low @ cold-path
```

This example is intentionally optional. The reviewer should preserve simple code when it is still clear, and only recommend a pattern when there is evidence that growth or churn justifies the extra abstraction.
