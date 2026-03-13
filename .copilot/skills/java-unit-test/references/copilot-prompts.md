# Copilot Prompt Templates for Java Test Generation

Use these comment patterns above test methods or classes to guide AI-assisted test generation.

## Complete Test Class Generation
```java
// Generate comprehensive unit tests for [ClassName]
// Include:
// - Happy path scenarios for all public methods
// - Edge cases: null inputs, empty collections, boundary values
// - Error scenarios with appropriate exception testing
// - Mock setup for all dependencies
// - @ParameterizedTest for data-driven scenarios
// - AAA pattern with AssertJ assertions
// - @Nested classes for logical grouping
```

## Fixing Failing Tests
```java
// Fix this failing test — modify TEST only, never production code
// Error: [paste error message]
// Likely causes: incorrect mock setup, wrong assertions, missing lenient()
// If production code is buggy: document current behavior + add TODO
```

## Improving Existing Tests
```java
// Improve this test:
// - Clear descriptive names (methodName_scenario_expectedBehavior)
// - Test data builders for complex objects
// - AssertJ assertions replacing assertEquals
// - @ParameterizedTest for similar scenarios
// - @BeforeEach for common setup extraction
```

## By Class Type

### Utility Classes
```java
// Generate tests for utility class with:
// - @ParameterizedTest with @CsvSource for multiple input/output
// - Edge cases: null, empty strings, boundary values
// - Locale-specific tests (TH/EN) if applicable
// - Buddhist era conversion (+543 years) for Thai dates
// - Exact output format verification
```

### Service Classes
```java
// Generate service tests with:
// - @Mock all external dependencies
// - @InjectMocks for service under test
// - Common mocks in @BeforeEach with lenient()
// - Business scenarios: success, validation errors, external failures
// - verify() for mock interactions
// - ArgumentCaptor for complex parameter verification
// - assertThatThrownBy() for exception testing
```

### Controller Classes
```java
// Generate controller tests with:
// - MockMvc + @MockBean
// - HTTP status codes and response structure
// - Request/response JSON mapping
// - Validation annotation testing
// - jsonPath() for response verification
```

## Workflow
1. **Generate** — Start with basic test structure using comments above
2. **Run** — Use VS Code ▶️ button (java.test.editor.run)
3. **Analyze** — Review results in test panel
4. **Refine** — Add specific comments for missing scenarios
5. **Enhance** — Add edge cases and better assertions
