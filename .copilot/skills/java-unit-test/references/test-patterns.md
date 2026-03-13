# Test Generation Patterns by Class Type

## Utility / Formatter Classes

```java
@ExtendWith(MockitoExtension.class)
class UtilityClassTest {
    @InjectMocks private UtilityClass utility;

    @ParameterizedTest
    @CsvSource({"input1,expected1", "input2,expected2", "edgeCase,expectedEdge"})
    void methodName_variousInputs_returnsExpected(String input, String expected) {
        assertThat(utility.methodName(input)).isEqualTo(expected);
    }

    @Test
    void methodName_nullInput_throwsException() {
        assertThatThrownBy(() -> utility.methodName(null))
            .isInstanceOf(IllegalArgumentException.class);
    }
}
```

## Service Classes

```java
@ExtendWith(MockitoExtension.class)
class ServiceClassTest {
    @Mock private ExternalClient client;
    @Mock private Repository repository;
    @InjectMocks private ServiceClass service;

    @Test
    void processRequest_validInput_returnsResult() {
        when(client.call(any())).thenReturn(mockResponse);
        var result = service.processRequest(validInput);
        assertThat(result).isNotNull();
        verify(client).call(any());
    }

    @Test
    void processRequest_clientFails_throwsException() {
        when(client.call(any())).thenThrow(new RuntimeException("timeout"));
        assertThatThrownBy(() -> service.processRequest(input))
            .isInstanceOf(ServiceException.class);
    }
}
```

## Controller Classes

```java
@ExtendWith(MockitoExtension.class)
@AutoConfigureMockMvc
class ControllerClassTest {
    @MockBean private ServiceClass service;
    private MockMvc mockMvc;

    @Test
    void endpoint_validRequest_returnsOk() throws Exception {
        when(service.method(any())).thenReturn(expectedResponse);
        mockMvc.perform(get("/api/endpoint").contentType(APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.field").value("expected"));
    }

    @Test
    void endpoint_invalidRequest_returnsBadRequest() throws Exception {
        mockMvc.perform(post("/api/endpoint")
                .contentType(APPLICATION_JSON)
                .content("{}"))
            .andExpect(status().isBadRequest());
    }
}
```

## Common Fix Patterns

```java
// Fix: lenient mock for unused stubbing warnings
lenient().when(mockService.method()).thenReturn(defaultResponse);

// Fix: flexible argument matching
when(mockService.process(argThat(arg -> arg.getField().equals("val")))).thenReturn(response);

// Fix: capture complex arguments
ArgumentCaptor<RequestType> captor = ArgumentCaptor.forClass(RequestType.class);
verify(mockClient).call(captor.capture());
assertThat(captor.getValue().getField()).isEqualTo("expected");

// Fix: flaky time-dependent tests
when(clockProvider.now()).thenReturn(LocalDateTime.of(2023, 1, 1, 12, 0));

// Fix: resource cleanup
@AfterEach void cleanup() { resetStaticMocks(); }
```

## Edge Case Patterns with @Nested

```java
@Nested
class EdgeCases {
    @Test
    void method_nullInput_throwsException() {
        assertThatThrownBy(() -> service.method(null))
            .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void method_emptyCollection_returnsEmpty() {
        assertThat(service.method(List.of())).isEmpty();
    }

    @Test
    void method_boundaryValue_handlesCorrectly() {
        assertThat(service.method(Integer.MAX_VALUE)).isNotNull();
    }
}
```
