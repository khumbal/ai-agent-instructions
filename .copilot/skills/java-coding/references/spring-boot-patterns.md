# Spring Boot Code Patterns

## REST Controller
```java
@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
public class CustomerController {
    private final CustomerService customerService;

    @GetMapping("/{id}")
    public ResponseEntity<CustomerResponse> getCustomer(@PathVariable Long id) {
        return ResponseEntity.ok(customerService.findById(id));
    }

    @PostMapping
    public ResponseEntity<CustomerResponse> createCustomer(
            @Valid @RequestBody CustomerRequest request) {
        var response = customerService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
```

## Service Layer
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class CustomerServiceImpl implements CustomerService {
    private final CustomerRepository repository;
    private final CustomerMapper mapper;

    @Override
    @Transactional(readOnly = true)
    public CustomerResponse findById(Long id) {
        return repository.findById(id)
            .map(mapper::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Customer", id));
    }

    @Override
    @Transactional
    public CustomerResponse create(CustomerRequest request) {
        var entity = mapper.toEntity(request);
        var saved = repository.save(entity);
        log.info("Created customer: id={}", saved.getId());
        return mapper.toResponse(saved);
    }
}
```

## Global Exception Handler
```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        log.warn("Resource not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("NOT_FOUND", ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        var errors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDATION_ERROR", String.join(", ", errors)));
    }
}
```

## Custom Business Exception
```java
public class BusinessException extends RuntimeException {
    private final String errorCode;
    
    public BusinessException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }
}

// Usage in service
if (!policy.isValid(request)) {
    throw new BusinessException("POLICY_VIOLATION", 
        "Request violates " + policy.getName());
}
```
