---
name: Core Software Engineering Principles
description: Essential engineering principles for all code
paths:
  - "**/*.py"
  - "**/*.md"
  - "**/*.js"
  - "**/*.json"
  - "**/*.vue"
---

## Code Quality

- Write self-documenting code with clear names
- Keep functions small and single-purpose (SRP)
- Follow DRY - extract duplicated logic
- Avoid deep nesting - use early returns
- Remove dead code and commented code

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**:: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Security & Safety

- Never hardcode secrets or credentials
- Validate and sanitize all user inputs
- Use environment variables for configuration
- Log errors but never log sensitive data

## Testing & Quality

- Write tests for critical business logic
- Test behavior, not implementation
- Use descriptive test names

## Version Control

- Keep commits atomic and focused
- Never commit sensitive data

## Error Handling

- Fail fast with clear error messages
- Use specific exceptions, not generic ones
- Include context in error messages

## Code Review

- Review for correctness, readability, and maintainability (not just bugs)
- Check for security vulnerabilities and performance issues
- Ensure tests cover new functionality and edge cases
- Verify documentation is updated
- Approve only when you'd be comfortable maintaining the code
