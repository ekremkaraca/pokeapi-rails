# CI Test Implementation

This document describes the implementation of automated tests in GitHub Actions CI.

## Overview

Three test jobs have been added to `.github/workflows/ci.yml` to run different test suites in parallel:

1. **test_smoke** - Ultra-fast subset of integration tests (30-60 seconds)
2. **test_integration** - Full integration test suite (~3-5 minutes)
3. **test_models_and_services** - Model and service/importer tests (~2-3 minutes)

## Test Jobs

### test_smoke

Runs a focused subset of key integration tests for immediate feedback on every PR.

**Purpose:**
- Catch configuration errors
- Verify app boots and responds
- Detect obvious breakage fast
- **Fail the build** when tests fail (prevents broken code from passing CI)
- Provide quick CI feedback (30-60 seconds)

**Tests Run:**
- `test/integration/api/v2/pokemon_controller_test.rb`
- `test/integration/api/v3/pokemon_controller_test.rb`
- `test/integration/api/v3/ability_controller_test.rb`
- `test/integration/home_controller_test.rb`
- `test/integration/api/v2/pokemon_encounters_controller_test.rb`

**Command:**
```bash
bin/rails test test:integration_smoke
```

**Behavior:**
- Tests run sequentially, failing on first error
- CI build shows ❌ when any test fails
- Prevents broken code from passing checks

### test_integration

Runs all integration tests for both `/api/v2/*` and `/api/v3/*` endpoints.

**Purpose:**
- Full API contract verification
- 99 integration tests covering all endpoints
- List, detail, filtering, pagination behavior

**Command:**
```bash
bin/rails test test/integration
```

### test_models_and_services

Runs model tests and service/importer tests together.

**Purpose:**
- Verify ActiveRecord associations
- Test CSV import correctness
- Validate business logic in services
- 4 model tests + 51 service tests

**Command:**
```bash
bin/rails test test/models test/services
```

## Rake Tasks Created

All test tasks are in `lib/tasks/pokeapi_test.rake` and can be run locally:

```bash
# Prepare test database
RAILS_ENV=test SKIP_JS_BUILD=1 bin/rails db:prepare

# Run smoke tests (fast subset for CI)
RAILS_ENV=test SKIP_JS_BUILD=1 bin/rails test \
  test/integration/api/v2/pokemon_controller_test.rb \
  test/integration/api/v3/pokemon_controller_test.rb \
  test/integration/api/v3/ability_controller_test.rb \
  test/integration/home_controller_test.rb \
  test/integration/api/v2/pokemon_encounters_controller_test.rb

# Run all integration tests
RAILS_ENV=test SKIP_JS_BUILD=1 bin/rails test test/integration

# Run model tests only
RAILS_ENV=test SKIP_JS_BUILD=1 bin/rails test test/models

# Run service tests only
RAILS_ENV=test SKIP_JS_BUILD=1 bin/rails test test/services

# Run lib tests (parity tools, gem runtime smoke)
bin/rails test test:lib

# Run all tests
bin/rails test test:all
```

## Benefits

### Before
- ❌ No tests in CI
- ❌ Had to manually verify tests pass locally
- ❌ Slow feedback on PRs
- ❌ Unclear quality signal to external reviewers

### After
- ✅ **Test failure detection** - Tests now properly fail when tests fail, raising errors to break CI
- ✅ **Fast smoke tests** (30-60 seconds) catch configuration errors and obvious breakage
- ✅ **Parallel test execution** - 3 jobs run simultaneously
- ✅ **Clear quality signal** - Green checkmarks accurately reflect test status
- ✅ **Guardrails** - Can't merge failing tests (tests now fail builds)
- ✅ **Reproducible environment** - Same test environment for everyone
- ✅ **Comprehensive coverage** - All 157 test files can be run

## Test Coverage Summary

| Test Type | Count | Location |
|-----------|-------|----------|
| Integration | 99 | `test/integration/api/*` + other integration tests |
| Model | 4 | `test/models/*` |
| Service | 51 | `test/services/*` |
| Lib | 3 | `test/lib/*` |
| **Total** | **157** | |

Note: Smoke tests run ~5 of the 99 integration tests for fast feedback.

## CI Workflow Structure

```yaml
jobs:
  test_smoke:               # Fast feedback (30-60s)
  test_integration:         # Full API tests (3-5 min)
  test_models_and_services: # Model/service tests (2-3 min)
  scan_ruby:                # Brakeman + Bundler-audit
  lint:                     # RuboCop + OpenAPI validation
```

All test jobs run in parallel, so total CI time is ~5-7 minutes max.

## Usage in GitHub Actions

All jobs run automatically on:
- Pull requests to `master` branch
- Pushes to `master` branch

Developers can see job results in the "Checks" tab of each PR with status indicators (✓/✗).

## Future Improvements

1. **Add test coverage badge** - Use SimpleCov to generate coverage reports
2. **Split integration tests** - If growth continues, could split v2/v3 tests separately
3. **Optimize smoke tests** - Add more endpoints to smoke suite for better coverage
4. **Test parallelization** - Consider matrix-based parallelization if test time grows
