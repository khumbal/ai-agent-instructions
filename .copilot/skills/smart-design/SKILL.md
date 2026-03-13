---
name: smart-design
description: "Pragmatic design pattern & architecture skill — guides foundation, structure, and architecture decisions using design patterns wisely, not dogmatically. Applies patterns only when they solve real problems, favoring simplicity and clarity over textbook perfection. Use this skill when designing new systems, planning module structure, choosing architecture patterns, making structural decisions, decomposing complex features, or when the user asks to design, architect, structure, plan, or organize code — even if they just say 'how should I build this'."
argument-hint: "The system, feature, or module to design"
metadata:
  author: phumin-k
  version: "1.1"
  scope: "**"
  tier: T1
  triggers:
    - "design"
    - "architecture"
    - "patterns"
    - "structure"
    - "module planning"
---

# Smart Design — Pragmatic Design Patterns & Architecture

## Philosophy

> "How can I come up with the simplest possible design, in a way that's easy for anyone to understand?"
> — The Pragmatic Engineer

Design patterns are **tools, not goals**. Use them when they solve a real problem. Don't force a pattern to feel "professional" — forced patterns create complexity that harms the team.

**The golden rule:** If you can't explain WHY a pattern is needed in one sentence, you don't need it yet.

## When to use this skill

- Designing a new system, module, or feature from scratch
- Planning code structure and file/folder organization
- Choosing between architectural approaches
- Decomposing a complex feature into manageable parts
- Reviewing or improving existing architecture
- Answering "how should I build this?" questions

## ⚖️ The Pragmatic Balance

```
Too Simple          ← SWEET SPOT →          Over-Engineered
─────────────────────────────────────────────────────────────
Spaghetti code       Clear structure         AbstractFactoryFactory
No separation        Right abstractions      12-layer architecture
God objects          Single responsibility   1 class per method
Copy-paste           DRY where it matters    Premature abstraction
```

**Aim for the sweet spot** — enough structure to be maintainable, not so much that it's hard to navigate.

## Hard Rules

- **Solve today's problem** — don't build for imaginary future requirements (YAGNI)
- **Simplicity wins** — if two designs solve the same problem, pick the simpler one
- **Justify every pattern** — document WHY (one sentence) when introducing a pattern
- **Patterns serve code, not ego** — never add complexity to look sophisticated
- **Refactor into patterns** — don't pre-architect; let patterns emerge from real needs
- **Team readability > textbook purity** — code is read 10x more than written
- **One pattern per problem** — never stack patterns unnecessarily

## Decision Framework

### Step 1: Understand the Problem

Before choosing any pattern, answer:

```
- [ ] What is the core problem?
- [ ] Who are the consumers (API clients, UI, other services)?
- [ ] What are the non-functional requirements (scale, performance, team size)?
- [ ] What's the simplest thing that could work?
- [ ] Will this codebase be maintained by 1 person or a team?
```

### Step 2: Evaluate Complexity

| Project Scale | Recommended Approach |
|--------------|---------------------|
| Script / CLI tool | No patterns needed — flat functions, clear naming |
| Small app (1-3 devs) | Basic separation of concerns, minimal layers |
| Medium app (3-8 devs) | Clear module boundaries, defined interfaces, selective patterns |
| Large app (8+ devs) | Explicit architecture, enforced boundaries, documented patterns |

### Step 3: Choose Patterns Wisely

Use the **Pattern Selection Matrix** below — match your problem to a pattern, never the reverse.

## Pattern Selection Matrix

### Structural Patterns — "How do I organize code?"

| Problem | Pattern | When to Use | When to SKIP |
|---------|---------|-------------|--------------|
| Code has no separation of concerns | **Layered Architecture** (Controller → Service → Repository) | Multi-layer apps with DB, API, UI | Simple scripts, single-responsibility tools |
| Module boundaries are unclear | **Module Pattern** (cohesive folders with clear APIs) | Any app > 5 files | Tiny projects |
| Need to hide complex subsystem | **Facade** | Wrapping 3+ APIs/libraries into one interface | When there's only 1 thing to wrap |
| Incompatible interfaces | **Adapter** | Integrating external libraries, legacy code | Internal code you control — just refactor |
| Need to add behavior without modifying | **Decorator** | Cross-cutting concerns (logging, caching, auth) | When you can just modify the original |
| Shared resources | **Singleton** (or DI container) | Config, DB connections, loggers | Business logic — leads to hidden coupling |

### Behavioral Patterns — "How do I handle actions?"

| Problem | Pattern | When to Use | When to SKIP |
|---------|---------|-------------|--------------|
| Complex conditional logic (many if/else) | **Strategy** | 3+ interchangeable algorithms | 2 cases — just use if/else |
| Object behaves differently based on state | **State Machine** | Workflows, wizards, order status | Simple flags — boolean is fine |
| Need to react to events | **Observer / Event Emitter** | Decoupled notifications, UI updates | 1 listener — just call the function |
| Need to process in steps | **Pipeline / Chain of Responsibility** | Middleware, validation chains, data transforms | 2 steps — just call sequentially |
| Need to encapsulate requests | **Command** | Undo/redo, task queues, audit logs | Simple CRUD — just call the service |
| Complex object creation | **Builder** | Objects with 5+ optional params, configs | Simple objects — just use constructor |
| Need to create families of related objects | **Factory** | Multiple implementations of same interface | Only 1 implementation — just `new` it |

### Architectural Patterns — "How do I structure the system?"

| Problem | Pattern | When to Use | When to SKIP |
|---------|---------|-------------|--------------|
| Frontend + Backend coupling | **API-first design** | Any web app | Static sites |
| Business logic scattered everywhere | **Service Layer** | Apps with complex business rules | CRUD-only apps |
| Domain is complex with many rules | **Domain-Driven Design (lite)** | Rich business domains, enterprise | Simple data in/out apps |
| Need independent deployability | **Microservices** | Large teams, independent scaling needs | Small teams — use modular monolith |
| Need async processing | **Event-Driven / Message Queue** | Background jobs, notifications, integrations | Synchronous-only workflows |
| Need to separate read/write models | **CQRS** | Different read/write scaling, complex queries | Simple CRUD — massive overkill |

## Design Workflow

```
1. UNDERSTAND  →  "What problem am I solving?"
2. SIMPLIFY    →  "What's the simplest design that works?"
3. STRUCTURE   →  "Where does each responsibility live?"
4. PATTERN?    →  "Does a known pattern fit naturally?" (if no → don't force it)
5. VALIDATE    →  "Can a new team member understand this in 15 minutes?"
6. DOCUMENT    →  "One paragraph: what pattern, why, what trade-off"
```

## Practical Architecture Templates

### Template A: Simple App (startup / POC / small team)

```
src/
├── routes/          # HTTP handlers (thin — parse request, call service, return response)
├── services/        # Business logic (pure functions preferred)
├── lib/             # Shared utilities, helpers
├── types/           # Type definitions
└── index.ts         # Entry point + server setup
```

**Rules:** No more than 3 layers. Services can call other services. No abstractions until duplication > 2.

### Template B: Medium App (growing team / multiple features)

```
src/
├── modules/
│   ├── users/
│   │   ├── user.routes.ts
│   │   ├── user.service.ts
│   │   ├── user.types.ts
│   │   └── user.repository.ts    # Only if DB access is complex
│   ├── billing/
│   │   ├── billing.routes.ts
│   │   ├── billing.service.ts
│   │   └── billing.types.ts
│   └── shared/                   # Cross-module utilities
├── lib/                          # Framework-agnostic utilities
├── types/                        # Global types
└── index.ts
```

**Rules:** Each module is self-contained. Modules communicate through services (not direct imports). Extract `repository` only when data access logic is complex.

### Template C: Large App (enterprise / many teams)

```
src/
├── modules/
│   ├── users/
│   │   ├── api/                  # Routes + DTOs
│   │   ├── domain/               # Business logic + entities
│   │   ├── infrastructure/       # DB, external APIs
│   │   └── index.ts              # Module public API
│   └── ...
├── shared/
│   ├── kernel/                   # Shared domain concepts
│   ├── infrastructure/           # Cross-cutting (logging, auth, events)
│   └── lib/                      # Pure utilities
└── index.ts
```

**Rules:** Strict module boundaries. Import only through module's `index.ts` (public API). Domain layer has zero framework dependencies.

## Anti-Patterns to Avoid

### ❌ Pattern Fever
Adding patterns "just in case" — creates unnecessary indirection and complexity.
**Fix:** Wait until the pain of NOT having the pattern is real.

### ❌ Abstraction Addiction
Creating interfaces/abstractions for everything, even when there's only one implementation.
**Fix:** Extract interface when you have 2+ implementations or need testability via mocking.

### ❌ Layer Cake Architecture
Forcing every request through 7+ layers (Controller → Validator → Mapper → Service → DomainService → Repository → DAO).
**Fix:** Use the minimum layers needed. Skip layers that just pass through.

### ❌ Premature Optimization
Designing for 1M users when you have 100.
**Fix:** Design for 10x current scale, not 1000x. Refactor when you actually grow.

### ❌ Resume-Driven Development
Picking technology/patterns to learn something new vs. solving the problem.
**Fix:** Use boring technology that works. Innovation budget goes to business differentiators.

### ❌ Cargo Cult Patterns
Copying patterns from big tech without understanding the problem they solved at that scale.
**Fix:** Ask "do I have the same problem?" — if not, simpler is better.

## Pattern Introduction Checklist

Before adding ANY pattern to the codebase:

```
- [ ] I can explain the problem it solves in one sentence
- [ ] I've verified the simpler approach is insufficient
- [ ] The pattern reduces complexity (not adds it)
- [ ] A new team member can understand it within 15 minutes
- [ ] I've documented WHY in a brief comment or doc
- [ ] The pattern fits the project scale (not over/under-engineered)
```

## SOLID — The Practical Version

Don't memorize acronyms — internalize the intent:

| Principle | Practical Rule | Example |
|-----------|---------------|---------|
| **S** — Single Responsibility | Each file/class does ONE job | `user.service.ts` doesn't send emails — it calls `notification.service.ts` |
| **O** — Open/Closed | Add new behavior without modifying existing code | Use strategy/plugin pattern for payment methods, not if/else chain |
| **L** — Liskov Substitution | Subtypes must be drop-in replacements | If `PremiumUser extends User`, all User code must work with PremiumUser |
| **I** — Interface Segregation | Don't force implementers to implement unused methods | Split `IRepository<CRUD>` into `IReader` + `IWriter` if some only read |
| **D** — Dependency Inversion | Depend on abstractions at system boundaries | Inject `EmailSender` interface, not `SendGridClient` directly |

**When to apply SOLID:**
- **S** — Always. This is just good hygiene.
- **O** — When you have 3+ variants or expect more.
- **L** — When using inheritance (prefer composition first).
- **I** — When interfaces grow beyond 5 methods.
- **D** — At system boundaries (external APIs, databases, third-party libs). Not for internal code.

## Output

After designing, provide:

1. **Architecture Decision** — What pattern/structure, and WHY (one paragraph)
2. **File/Folder Structure** — Clear tree showing where code lives
3. **Responsibility Map** — What each layer/module owns
4. **Trade-offs** — What you gain AND what you give up
5. **Growth Path** — How this design evolves when the app grows (next natural step)

## References

See [Design Pattern Quick Reference](./references/pattern-quick-ref.md) for concise pattern summaries with code examples.
