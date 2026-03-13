# Design Pattern Quick Reference

> Concise examples — use as starting point, adapt to your language/framework.

---

## Structural Patterns

### Layered Architecture
```
// Route (thin) → Service (logic) → Repository (data)
// Route: parse request, call service, return response
// Service: business rules, validation, orchestration
// Repository: data access only
```

### Facade
```typescript
// BEFORE: Caller knows 3 APIs
await stripe.createCustomer(data);
await mailgun.sendWelcome(email);
await analytics.track('signup', userId);

// AFTER: One clean interface
class OnboardingFacade {
  async signup(data: SignupData) {
    const customer = await this.billing.createCustomer(data);
    await this.mailer.sendWelcome(data.email);
    await this.analytics.track('signup', customer.id);
    return customer;
  }
}
```

### Adapter
```typescript
// Wrap external library to match YOUR interface
interface PaymentGateway {
  charge(amount: number, currency: string): Promise<PaymentResult>;
}

class StripeAdapter implements PaymentGateway {
  constructor(private stripe: Stripe) {}
  
  async charge(amount: number, currency: string) {
    const result = await this.stripe.paymentIntents.create({ amount, currency });
    return { id: result.id, status: result.status === 'succeeded' ? 'ok' : 'failed' };
  }
}
```

### Decorator
```typescript
// Add behavior without modifying original
function withLogging<T extends (...args: any[]) => any>(fn: T, label: string): T {
  return ((...args: any[]) => {
    console.log(`[${label}] called with`, args);
    const result = fn(...args);
    console.log(`[${label}] returned`, result);
    return result;
  }) as T;
}

const getUser = withLogging(userService.getById, 'getUser');
```

---

## Behavioral Patterns

### Strategy
```typescript
// BEFORE: if/else chain
function calculatePrice(type: string, base: number) {
  if (type === 'standard') return base;
  if (type === 'premium') return base * 0.9;
  if (type === 'enterprise') return base * 0.7;
}

// AFTER: Strategy (when 3+ variants)
const pricingStrategies: Record<string, (base: number) => number> = {
  standard: (base) => base,
  premium: (base) => base * 0.9,
  enterprise: (base) => base * 0.7,
};

function calculatePrice(type: string, base: number) {
  return pricingStrategies[type](base);
}
```

### State Machine
```typescript
// Define transitions explicitly
const orderTransitions: Record<string, Record<string, string>> = {
  draft:      { submit: 'pending',   cancel: 'cancelled' },
  pending:    { approve: 'approved', reject: 'rejected', cancel: 'cancelled' },
  approved:   { ship: 'shipped' },
  shipped:    { deliver: 'delivered' },
  // terminal states: cancelled, rejected, delivered
};

function transition(currentState: string, action: string): string {
  const next = orderTransitions[currentState]?.[action];
  if (!next) throw new Error(`Invalid: ${action} from ${currentState}`);
  return next;
}
```

### Observer / Event Emitter
```typescript
// Decouple producer from consumers
class EventBus {
  private listeners = new Map<string, Set<Function>>();
  
  on(event: string, handler: Function) {
    if (!this.listeners.has(event)) this.listeners.set(event, new Set());
    this.listeners.get(event)!.add(handler);
  }
  
  emit(event: string, data: unknown) {
    this.listeners.get(event)?.forEach(fn => fn(data));
  }
}

// Usage: loosely coupled notification
eventBus.on('order.created', sendConfirmationEmail);
eventBus.on('order.created', updateInventory);
eventBus.on('order.created', notifyWarehouse);
```

### Pipeline / Chain
```typescript
// Process data through sequential steps
type Middleware<T> = (data: T, next: () => T) => T;

function pipeline<T>(data: T, steps: Array<(data: T) => T>): T {
  return steps.reduce((result, step) => step(result), data);
}

// Usage: validation pipeline
const validated = pipeline(formData, [
  trimWhitespace,
  normalizeEmail,
  validateRequired,
  sanitizeHtml,
]);
```

### Builder
```typescript
// Fluent construction for complex objects
class QueryBuilder {
  private query: QueryConfig = { table: '', conditions: [], limit: 100 };
  
  from(table: string) { this.query.table = table; return this; }
  where(condition: string) { this.query.conditions.push(condition); return this; }
  limit(n: number) { this.query.limit = n; return this; }
  build() { return this.query; }
}

const query = new QueryBuilder()
  .from('users')
  .where('active = true')
  .where('role = "admin"')
  .limit(10)
  .build();
```

### Factory
```typescript
// Create objects without specifying exact class
interface Notification {
  send(message: string): Promise<void>;
}

function createNotification(channel: string): Notification {
  switch (channel) {
    case 'email': return new EmailNotification();
    case 'sms': return new SmsNotification();
    case 'push': return new PushNotification();
    default: throw new Error(`Unknown channel: ${channel}`);
  }
}
```

### Command
```typescript
// Encapsulate action + undo
interface Command {
  execute(): void;
  undo(): void;
}

class MoveItemCommand implements Command {
  constructor(private item: Item, private from: number, private to: number) {}
  execute() { moveItem(this.item, this.to); }
  undo() { moveItem(this.item, this.from); }
}

// Usage: undo stack
const history: Command[] = [];
function executeCommand(cmd: Command) {
  cmd.execute();
  history.push(cmd);
}
function undoLast() {
  history.pop()?.undo();
}
```

---

## Architectural Patterns

### Service Layer
```typescript
// Centralize business logic
class UserService {
  constructor(
    private repo: UserRepository,
    private mailer: MailService,
  ) {}

  async register(data: RegisterInput) {
    // Validation
    if (await this.repo.existsByEmail(data.email)) {
      throw new ConflictError('Email already registered');
    }
    // Business logic
    const user = await this.repo.create(data);
    await this.mailer.sendWelcome(user.email);
    return user;
  }
}
```

### Repository Pattern
```typescript
// Abstract data access
interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(data: CreateUserInput): Promise<User>;
  update(id: string, data: Partial<User>): Promise<User>;
}

// Implementation can be swapped (Postgres, MongoDB, in-memory for tests)
class PostgresUserRepository implements UserRepository {
  async findById(id: string) { return db.query('SELECT * FROM users WHERE id = $1', [id]); }
  // ...
}
```

### Module Pattern
```typescript
// src/modules/billing/index.ts — public API
export { BillingService } from './billing.service';
export { type Invoice, type PaymentResult } from './billing.types';
// Internal implementation stays private (not exported)

// Other modules import ONLY from index.ts
import { BillingService } from '@/modules/billing';
```

---

## Decision Shortcuts

| Situation | Just Do This |
|-----------|-------------|
| 2 cases | `if/else` — no pattern needed |
| 3+ cases of same type | Strategy or Factory |
| Complex object with many optional fields | Builder |
| Wrapping external API | Adapter |
| Multiple things react to one event | Observer |
| Multi-step processing | Pipeline |
| Need undo/redo | Command |
| State with defined transitions | State Machine |
| Complex subsystem with many parts | Facade |
| Need to compose behaviors | Decorator |
