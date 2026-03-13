---
applyTo: '**/*.{css,scss,less,tsx,jsx,svelte,astro,html,vue}'
description: 'UI/UX rules for frontend interactive elements and styling.'
---

# Frontend UI/UX Rules

- **AVOID CSS transforms** for interactive elements (buttons, links) — causes visual glitches
- Use opacity, background, border, box-shadow for hover/active states
- Only use transforms for intentional animations (spinners, modals)
