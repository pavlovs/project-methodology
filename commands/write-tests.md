# /write-tests

You are writing **missing tests** for existing code. Follow this protocol exactly.

## Context (pre-computed at invocation)

```
Branch:        $(git branch --show-current 2>/dev/null || echo "unknown")
Test files:    $(find . -name "test_*.py" -o -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.*" 2>/dev/null | grep -v node_modules | grep -v __pycache__ | head -20 || echo "none found")
Test runner:   $(ls pytest.ini setup.cfg pyproject.toml jest.config.* vitest.config.* 2>/dev/null | head -3 || echo "unknown")
Current tests: $(python -m pytest --collect-only -q 2>/dev/null | tail -1 || echo "unknown")
```

## Scope

If the user specified a file, function, or module: write tests for that.
Otherwise: identify the least-tested code and write tests there first.

## Step 1 — Read existing tests

Before writing anything, read all existing test files to understand:
- Testing framework and patterns in use (fixtures, mocks, parametrize, etc.)
- Naming conventions (`test_function_name_scenario`)
- What's already covered — do not duplicate
- Any test helpers or factories already defined

## Step 2 — Read the code under test

Read the target file(s) completely. For each public function or class, identify:
- **Happy path** — normal inputs, expected outputs
- **Edge cases** — empty input, zero, None, boundary values, max size
- **Error cases** — invalid input, missing dependencies, external API failure
- **Side effects** — DB writes, file writes, external calls that need mocking

## Step 3 — Check coverage gaps (if available)

Run coverage if the project has it configured:
```bash
pytest --tb=no -q --co 2>/dev/null  # collect test names
```

Identify functions with no corresponding tests.

## Step 4 — Write tests

Follow the existing project patterns exactly. Do not introduce a new framework or pattern if one already exists.

For each function under test, write:

1. **One happy-path test** — canonical input → expected output
2. **Edge case tests** — at least 2 meaningful edge cases per function
3. **Error case tests** — what happens when it fails (exception, return value, log message)

Test structure:
```python
def test_{function}_{scenario}():
    # Arrange
    ...
    # Act
    result = function_under_test(...)
    # Assert
    assert result == expected
```

Mocking rules:
- Mock external API calls, HTTP requests, and DB connections — never let tests hit real external services
- Do not mock the module under test itself
- Prefer `pytest` fixtures over setup/teardown methods
- Use `pytest.mark.parametrize` for multiple input/output pairs

## Step 5 — Run and confirm

Run the new tests:
```bash
pytest {new_test_file} -v
```

All new tests must pass before you present them. If a test reveals a bug in the production code, flag it separately — do not silently fix it as part of this command (it belongs in a milestone).

## Step 6 — Report

Tell the user:
1. How many tests were added and for which functions
2. Any bugs or unexpected behavior discovered (do not fix silently)
3. Coverage gaps that are out of scope for this command (e.g., integration tests that need real infrastructure)
4. Whether any existing tests were broken by the changes (should be none)
