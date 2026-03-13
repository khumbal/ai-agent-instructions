---
name: java-unit-test
description: Generates, fixes, and improves Java unit tests using JUnit 5, Mockito, and AssertJ. Handles test creation for service/controller/utility/DTO classes, debugging failing tests, refactoring legacy tests, and improving coverage. Use this skill whenever the user needs to write Java tests, fix broken tests, improve test quality, increase coverage, or work with any *Test.java files — even when they just say "test this class" or "why is this test failing".
argument-hint: "The Java class to test or failing test to fix"
metadata:
  author: phumin-k
  version: "3.1"
  scope: "**/*Test.java"
  tier: T2
  triggers:
    - "write test"
    - "fix test"
    - "coverage"
    - "unit test"
    - "test this class"
---

# Java Unit Test

## When to use this skill

Use when generating, fixing, or improving Java unit tests — including test creation for any class type, debugging failures, and improving coverage.

## Critical constraint

**Modify only test files** (`src/test/java/**/*Test.java`). Never change production code to make tests pass. If production code has bugs, document current behavior and add a TODO.

## Conditional workflow

1. Determine your task:

   **Generate new tests?** → Read source class → choose pattern by type:
   - Utility class → `@ParameterizedTest` with `@CsvSource`/`@MethodSource`
   - Service class → `@Mock` dependencies + `@InjectMocks` + business scenarios
   - Controller class → `MockMvc` + `@MockBean` + HTTP status/response
   - Model/DTO class → Constructor, equals/hashCode, serialization

   **Fix failing test?** → Read error message FIRST → match fix pattern:
   - `NullPointerException` → Check `@Mock` + `@InjectMocks` initialization
   - Mock verification fail → Use flexible matchers (`any()`, `argThat()`)
   - Assertion mismatch → Verify expectations match actual behavior
   - Flaky/timing → Mock time dependencies, avoid `Thread.sleep`
   - Spring context error → Use `@ExtendWith(MockitoExtension.class)` not `@SpringBootTest`

   **Improve existing tests?** → Assess quality against checklist below

## Test stack

- **JUnit 5** with `@ExtendWith(MockitoExtension.class)` (not `@RunWith`)
- **AssertJ** assertions: `assertThat()` (not `assertEquals`)
- **Mockito**: `@Mock`, `@InjectMocks`, `lenient().when()`
- **@ParameterizedTest** with `@CsvSource`/`@MethodSource` for data-driven tests
- `@SpringBootTest` only when Spring context is truly required

## Test structure: AAA pattern

```java
@Test
void methodName_scenario_expectedBehavior() {
    // ARRANGE
    when(mockDep.call(any())).thenReturn(mockResponse);
    // ACT
    var result = service.methodName(input);
    // ASSERT
    assertThat(result).isNotNull();
    verify(mockDep).call(any());
}
```

## Code templates

See [test generation patterns](./references/test-patterns.md) for complete templates per class type (Utility, Service, Controller) and common fix patterns.

## Feedback loop

After writing/modifying tests:

```
Write tests → Run → Pass? → Done
                ↓ No
         Read error → Apply fix → Run again (loop until green)
```

1. Run tests via `mvn test -pl module -Dtest=ClassNameTest`
2. If fails → read error message → match to fix pattern above
3. Apply fix to test code only
4. Run again → repeat until all pass
5. Check coverage meets threshold

## When production code has bugs

```java
@Test
@DisplayName("CURRENT BEHAVIOR: returns null for invalid input (BUG: should throw)")
void method_invalidInput_currentlyReturnsNull() {
    assertThat(service.method(invalidInput)).isNull();
    // TODO: File BUG-XXX - should throw IllegalArgumentException
}
```

## Quality checklist

- [ ] Test names: `methodName_scenario_expectedBehavior`
- [ ] AAA pattern clearly separated
- [ ] Edge cases: null, empty, boundary values
- [ ] No `@SpringBootTest` for pure unit tests
- [ ] AssertJ assertions throughout
- [ ] `@ParameterizedTest` for multiple input/output scenarios
- [ ] Coverage > 80% for business logic
- [ ] Each test < 1 second execution

## Reference files

- **[Test generation patterns](./references/test-patterns.md)**: Complete templates per class type and common fix patterns
- **[Copilot prompt templates](./references/copilot-prompts.md)**: Comment templates for guiding test generation
