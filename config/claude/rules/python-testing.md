---
name: Python Best Practices
paths:
  - "**/test_*.py"
  - "**/tests/**/*.py
---

# Python Testing Guidelines

- Write unit tests using pytest framework
- Use descriptive test function names that explain what is being tested
- Follow Arrange-Act-Assert pattern in tests
- Use fixtures for test setup and teardown
- Mock external dependencies in tests
- Aim for high test coverage of critical paths
- Always use pytest-mock and its MockerFixture for mocks, instead of unittest.mock
- Do not add comments or docstrings to test files
