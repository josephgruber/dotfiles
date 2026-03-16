---
name: Python Best Practices
---

# Type Hints & Type Safety

- Use type hints for all function parameters, return values, and class attributes
- Use typing module types (List, Dict, Optional, Union, etc.) for complex types
- Use None instead of Optional when Python 3.10+ union syntax (X | None) is clearer
- Add type hints to instance variables in __init__ methods
- Use Pydantic, TypedDict or dataclasses for structured data instead of plain dictionaries

## Documentation

- Write docstrings in Google format for all modules, classes, and functions
- Include Args, Returns, Raises, and Examples sections in docstrings where applicable
- Keep docstrings concise but complete - explain the "why" not just the "what"
- Document complex algorithms with inline comments

## Code Style & Standards

- Follow PEP 8 style guidelines strictly
- Use snake_case for functions and variables, PascalCase for classes, UPPER_CASE for constants
- Maximum line length of 88 characters (Black formatter standard)
- Use 4 spaces for indentation, never tabs
- Add blank lines to separate logical sections within functions
- Group imports in order: standard library, third-party, local imports
- NEVER use asserts except in unit tests

## Modern Python Features

- Use f-strings for string formatting, avoid %-formatting and .format()
- Use pathlib.Path for file operations instead of os.path
- Prefer dataclasses over namedtuples or plain classes for data structures
- Use structural pattern matching (match/case) for Python 3.10+ when appropriate
- Use walrus operator (:=) when it improves readability
- Use dict merge operator (|) and update operator (|=) for Python 3.9+

## Error Handling & Validation

- Use specific exceptions rather than bare Exception
- Implement proper exception handling with try/except blocks
- Always include error context in exception messages
- Use contextlib.suppress() for intentionally ignored exceptions
- Validate inputs early and fail fast with clear error messages
- Use assertions only for debugging, not for runtime validation

## Code Organization

- Keep functions small and focused (single responsibility principle)
- Limit function parameters to 5 or fewer, use dataclasses for more
- Organize code in order: imports, constants, classes, functions, main block
- Use private methods/attributes (prefix with _) for internal implementation details
- Group related functionality into classes or modules

## Best Practices

- Use list/dict/set comprehensions when they improve readability
- Prefer generators over lists for large datasets or streams
- Use context managers (with statements) for resource management
- Avoid mutable default arguments - use None and initialize in function body
- Use enumerate() instead of range(len()) for iteration with indices
- Use zip() for parallel iteration over multiple sequences
- Prefer "is None" over "== None" for None checks

## Testing

- Write unit tests using pytest framework
- Use descriptive test function names that explain what is being tested
- Follow Arrange-Act-Assert pattern in tests
- Use fixtures for test setup and teardown
- Mock external dependencies in tests
- Aim for high test coverage of critical paths
- Always use pytest-mock and it's MockerFixture for mocks, instead of unitest.mock

## Performance & Efficiency

- Use built-in functions and standard library when possible (they're optimized)
- Profile code before optimizing - don't prematurely optimize
- Use appropriate data structures (sets for membership tests, deques for queues)
- Cache expensive computations with functools.lru_cache or functools.cache
- Use generators for memory-efficient iteration over large datasets

## Security & Safety

- Never use eval() or exec() with user input
- Use secrets module for cryptographically secure random values
- Validate and sanitize all external inputs
- Use environment variables for sensitive configuration (never hardcode secrets)
- Use logging module instead of print() for production code

## Code Quality

- Remove commented-out code - use version control instead
- Avoid magic numbers - use named constants
- Keep nesting depth to 3 levels or less
- Remove unused imports and variables
- Use meaningful variable names that convey intent
- Avoid abbreviations unless they're widely understood

## Performance Optimization

- Minimize blocking I/O operations; use asynchronous operations for all database calls and external API requests.
- Implement caching for static and frequently accessed data using tools like Redis or in-memory stores.
- Optimize data serialization and deserialization with Pydantic.
- Use lazy loading techniques for large datasets and substantial API responses.
