---
name: Python Coding Standards
paths:
  - "**/*.py"
---

# Python Coding Standards

- Use type hints for all function parameters, return values, and class attributes
- Use built-in `list`, `dict`, `set`, `tuple` for type hints — not `typing.List`, `typing.Dict`, etc.
- Use `X | None` over `Optional[X]`
- Use Pydantic, TypedDict, or dataclasses for structured data instead of plain dicts
- Write docstrings in Google format
- Maximum line length of 120 characters
- NEVER use asserts except in unit tests
- Use `pathlib.Path` for file operations instead of `os.path`
- Limit function parameters to 5 or fewer, use dataclasses for more
