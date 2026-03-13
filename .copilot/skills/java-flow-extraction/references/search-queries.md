# Search Query Templates for Java Code Flow Extraction

## Finding Entry Points
```bash
rg "@RestController" -tjava
rg "@RequestMapping" -tjava
rg "@GetMapping|@PostMapping|@PutMapping|@DeleteMapping" -tjava
```

## Tracing Specific Flows
```bash
rg "ManagerName" -tjava           # Find all usages of a manager
rg "AuthenResult" -tjava          # Trace enum results
rg "ExitAction" -tjava            # Trace exit actions
rg "StageMapping" -tjava          # Trace stage mappings
rg "implements StageHandler" -tjava
```

## Finding State Holders
```bash
rg "TabletSession" -tjava         # Session objects
rg "session\." -tjava             # Session mutations
rg "Context" -tjava               # Context objects
```

## Finding External Integrations
```bash
rg "Client" -tjava --type-add 'java:*.java'  # Feign/HTTP clients
rg "Repository" -tjava            # Data repositories
rg "@FeignClient" -tjava          # Feign declarations
```

## Finding Exceptions
```bash
rg "throw new .*BusinessException" -tjava
rg "throw new .*ValidationException" -tjava
```

## Finding Decisions/Branching
```bash
rg "if \(" ManagerName.java | sed -E 's/.*if \(//;s/\).*//'
```

## Finding Logging (for sequence cross-checking)
```bash
rg 'log\.(info|warn|error)' -tjava
```

## Dependency Analysis
```bash
mvn dependency:tree               # External boundary analysis
jdeps -verbose:class target/classes  # Class relationships
```

## Extracting Public Method Signatures
```bash
rg --pcre2 "public\s+[^\(]+\(" src/.../ManagerName.java
```

## Finding All Enum Values
```bash
rg "AuthenResult\." -tjava        # All AuthenResult usages
rg "OverrideType\." -tjava        # All OverrideType usages
```
