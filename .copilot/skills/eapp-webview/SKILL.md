---
name: eapp-webview
description: Develops React-based tablet WebView applications with touch-optimized UI, native bridge communication, workflow routing systems, and responsive tablet layouts. Enforces reuse of existing components/utils/hooks before creating new ones. Use this skill whenever the user works on tablet webview features, e-app tablet UI, webview bridge communication, workflow routing, or any tablet-specific React development with native integration.
argument-hint: "The feature or component to develop"
metadata:
  author: phumin-k
  version: "3.1"
  scope: "**/*.{tsx,jsx,ts,js,css,scss}"
  tier: T2
  triggers:
    - "tablet"
    - "webview"
    - "React native bridge"
    - "e-app"
    - "touch UI"
---

# E-App Tablet WebView Development

## When to use this skill

Use when building tablet webview features, e-app UI components, native bridge communication, or workflow routing in the React-based tablet application.

## Conditional workflow

1. Determine what you're building:

   **New UI component?** → Search `src/components/` first → Extend or adapt existing → Create new only if nothing similar exists
   **Business logic?** → Check `src/functions/` and `src/services/` first
   **Navigation/routing?** → Use workflow routing system (config-driven, see below)
   **Native bridge call?** → Follow `src/communication.ts` patterns
   **Performance fix?** → Profile first → optimize renders/bridge calls

## Pre-analysis (mandatory)

Before writing any code:
1. Read README.md and package.json
2. **Search existing code** — never create new when reusable components exist:
   - `src/components/` — Button, Modal, Forms, Table, DatePicker, Icons, Text
   - `src/utils/` — helpers, logger, environment, validation
   - `src/hooks/` — custom hooks and workflow routing hooks
   - `src/services/` — API services and data layers
   - `src/functions/` — business logic
   - `src/providers/` — context providers and state management
   - `src/workflow/` — workflow routing and navigation

Use `semantic_search`, `file_search`, or `grep_search` to verify before creating anything.

## Tablet-specific constraints

These are non-negotiable rules specific to this project:

- **Touch targets**: Minimum 44px for ALL interactive elements
- **No CSS transforms on interactive elements** — causes visual glitches on tablet WebView. Use transitions on color, opacity, box-shadow instead
- **Layout**: CSS Grid/Flexbox, tablet-first design, handle orientation changes (landscape + portrait)
- **Performance**: Minimize bridge call frequency and payload size, batch UI updates
- **Security**: HTTPS in webview, input sanitization, XSS prevention

## WebView bridge communication

Follow existing `src/communication.ts` patterns strictly (low freedom — fragile API):

```typescript
// Type-safe native bridge interface
interface NativeBridge {
  sendMessage(type: string, payload: Record<string, unknown>): void;
  onMessage(handler: (message: BridgeMessage) => void): void;
}
```

Rules:
- Use existing message types and interfaces — do not create new ones without reviewing existing
- Handle bridge failures with error boundaries
- Validate all data crossing the bridge boundary

## Workflow routing system

- Configuration-driven approach (not hard-coded routes)
- Integrate with `WorkflowProvider` and dynamic component loading
- Use existing handlers and middleware patterns
- Implement error boundaries with fallback strategies

## Code standards

- **Logging**: Use `logger` function (not `console.log`). Check `shouldEnableConsoleLog()` for debug.
- **Types**: Proper TypeScript interfaces, no `any` (especially in bridge messages)
- **Error handling**: Error boundaries for webview crash handling, graceful connectivity changes

## Feedback loop

After implementing changes:
1. Verify touch interactions work on tablet (44px targets, no transform glitches)
2. Test bridge communication end-to-end
3. Test orientation changes
4. If any fails → fix → retest (loop until all pass)
