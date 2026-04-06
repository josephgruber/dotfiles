---
name: Core Engineering Principles
description: Opinionated engineering standards that override defaults
paths:
  - "**/*.py"
  - "**/*.js"
  - "**/*.vue"
---

# Core Engineering Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- Find root causes. No temporary fixes. Senior developer standards.
- Approve only when you'd be comfortable maintaining the code.

## DRY (Don't Repeat Yourself)

- Extract common logic into functions
- Create reusable components
- Share utilities across modules
- Avoid copy-paste programming

## YAGNI (You Aren't Gonna Need It)

- Don't build features before they're needed
- Avoid speculative generality
- Add complexity only when required
- Start simple, refactor when needed
