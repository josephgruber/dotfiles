---
name: Python Testing Standards
paths:
  - "**/test_*.py"
  - "**/tests/**/*.py"
---

# Python Testing Standards

- Always use pytest-mock and its MockerFixture for mocks, instead of unittest.mock
- Do not add comments or docstrings to test files
- Prefer factory functions or pytest.param over complex fixture hierarchies
- Use parametrize for testing multiple inputs against the same logic
