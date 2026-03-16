---
name: Core Software Engineering Principles
description: Essential engineering principles for all code
---

# Code Quality

- Write self-documenting code with clear names
- Keep functions small and single-purpose (SRP)
- Follow DRY - extract duplicated logic
- Avoid deep nesting - use early returns
- Remove dead code and commented code

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

- Write clear, descriptive commit messages
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
