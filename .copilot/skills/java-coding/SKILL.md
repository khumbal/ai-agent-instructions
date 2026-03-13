---
name: java-coding
description: Expert Java development covering Spring Boot applications, REST APIs, service layer patterns, dependency injection, error handling, and production-ready code. Applies clean architecture, proper exception handling, logging, and performance best practices. Use this skill when writing Java code, creating Spring Boot services, designing REST APIs, implementing business logic, or working with any .java files — including controllers, services, repositories, DTOs, and configuration classes.
argument-hint: "The Java class or feature to implement"
metadata:
  author: phumin-k
  version: "3.1"
  scope: "**/*.java"
  tier: T2
  triggers:
    - "write Java"
    - "Spring Boot"
    - "REST API"
    - "service layer"
    - "implement business logic"
---

# Java Coding

## When to use this skill

Use when writing or modifying Java code, creating Spring Boot services, designing REST APIs, implementing business logic, or working with any .java files.

## Conditional workflow

1. Determine what you're building:

   **New REST endpoint?** → Controller (thin) → Service (logic) → Repository (data)
   **Business logic?** → Service layer with `@Transactional`, proper error handling
   **New entity/DTO?** → Records for DTOs, entities separate from API surface
   **Bug fix?** → Read existing code first, understand the flow, fix with tests

## Architecture rules

Follow strict layered architecture:

```
Request → Controller → Service → Repository → Database
            ↓              ↓
         Validate      Business logic
         Map DTO       Transactions
         HTTP status   Error handling
```

- **Controller**: Thin — validate input, map DTOs, return HTTP status. No business logic.
- **Service**: Business rules, `@Transactional` boundaries, orchestrate repository calls.
- **Repository**: Data access only. Spring Data JPA methods.

## Code patterns

See [Spring Boot patterns](./references/spring-boot-patterns.md) for complete Controller, Service, Exception Handler, and Business Exception templates.

## Mandatory conventions

| Practice | Do | Don't |
|----------|-----|-------|
| DTOs | Separate request/response DTOs (Records) | Expose JPA entities in API |
| Transactions | `@Transactional` on service methods | `@Transactional` on controllers |
| Validation | `@Valid` on controller params | Manual null checks everywhere |
| Logging | SLF4J `@Slf4j`, structured context | `System.out.println` |
| Nulls | `Optional` returns, `@NonNull` | Return null from services |
| Dependencies | Constructor injection (`@RequiredArgsConstructor`) | Field injection (`@Autowired`) |

## Performance rules

- `@Transactional(readOnly = true)` for read operations
- Avoid N+1: use `@EntityGraph` or JOIN FETCH
- Pagination for list endpoints (`Pageable`)
- `@Cacheable` for frequently accessed, rarely changed data
- Profile before optimizing — don't guess

## Feedback loop

After writing/modifying code:
1. Run `mvn compile` → fix compile errors
2. Run relevant tests → fix failures
3. Check for missing error handling or edge cases
4. If any step fails → fix → restart from step 1