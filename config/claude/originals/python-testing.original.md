---
name: Python Testing Standards
paths:
  - "**/test_*.py"
  - "**/tests/**/*.py"
---

# Python Testing Standards

- Always use pytest-mock and its MockerFixture for mocks, instead of unittest.mock
- Always add return type `-> None` to test methods
- No docstrings on test functions
- No comments in test functions
- Prefer factory functions or pytest.param over complex fixture hierarchies
- Use parametrize for testing multiple inputs against the same logic
- Test names should be self-documenting (e.g., `test_initialization`, `test_record_delay_increments_counter`)
- When writing two tests with identical structure but different values, use `@pytest.mark.parametrize`.
- Follow module pattern for test cases files. One module = one test file.
- Place tests in the correct existing test file — ask if unsure
