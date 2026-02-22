# Next Targets

This document tracks concrete follow-up work after the v2/v3 association normalization and include-loader refactors.

## Priority Backlog

1. Data quality cleanup for placeholder prose content
   - Scope:
     - `db/data/v2/csv/item_prose.csv`
     - `db/data/v2/csv/move_effect_prose.csv`
   - Goal:
     - Prevent placeholder strings like `XXX new effect for ...` from appearing in API responses.
   - Approach:
     - Sanitize placeholder prose during import (preferred) and cover with importer tests.

2. Reduce complexity in `app/controllers/api/v2/move_controller.rb`
   - Keep behavior and query-budget expectations identical.
   - Consider extracting payload sections into dedicated presenter/service objects.

3. Split `app/controllers/concerns/api/v3/include_loaders.rb` into smaller units
   - Group loaders by domain (`pokemon`, `move`, `item`, `location`, etc.).
   - Preserve deterministic ordering and include-expansion budgets.

4. Harden raw SQL / string-query hotspots
   - Review for maintainability and clarity:
     - `app/controllers/api/v3/evolution_chain_controller.rb`
     - `app/controllers/api/v3/contest_effect_controller.rb`
     - `app/controllers/api/v3/machine_controller.rb`
     - SQL-heavy section in `app/controllers/concerns/api/v3/include_loaders.rb` (`pokemon_by_move_id`)

5. Narrow broad rescue in parity tooling
   - `lib/pokeapi/parity/response_diff.rb`
   - Replace broad rescue with expected error classes and clearer diagnostics.

6. Expand performance regression coverage for include-heavy v3 endpoints
   - Add query-budget regression tests for include paths with higher fanout.

## Current Focus

- Completed: target #1 (placeholder prose sanitization at import time).
- Completed: target #2 (`v2/move_controller` decomposition).
- Completed: target #3 (`v3/include_loaders` split into domain modules).
- Completed: target #4 (SQL/string-query hardening in selected v3 controllers).
- Completed: target #5 (narrow broad rescue in parity tooling).
- Completed: target #6 (include-heavy v3 performance regression coverage).

Implemented:
- Added placeholder sanitizer in importer base (`sanitize_placeholder_text`).
- Applied to:
  - `app/services/pokeapi/importers/item_prose_importer.rb`
  - `app/services/pokeapi/importers/move_effect_prose_importer.rb`
- Added focused importer tests:
  - `test/services/pokeapi/importers/item_prose_importer_test.rb`
  - `test/services/pokeapi/importers/move_effect_prose_importer_test.rb`

Implemented (target #2, phase 1):
- Extracted move detail payload and helper logic into:
  - `app/controllers/concerns/api/v2/move_detail_payload.rb`
- Reduced `app/controllers/api/v2/move_controller.rb` to a thin wrapper that includes:
  - `NameSearchableResource`
  - `MoveDetailPayload`
- Verified behavior parity with integration tests:
  - `test/integration/api/v2/move_controller_test.rb`
  - `test/integration/api/v2/pokemon_controller_test.rb`
  - `test/integration/api/v2/type_controller_test.rb`

Implemented (target #2, phase 2):
- Restructured `MoveDetailPayload` internals into section builders:
  - `core_fields`
  - `relation_fields`
  - `text_fields`
  - `meta_fields`
- Kept payload shape unchanged (`detail_payload` now merges these sections).

Implemented (target #2, phase 3):
- Split payload logic into focused sub-concerns:
  - `app/controllers/concerns/api/v2/move_payload/relation_fields.rb`
  - `app/controllers/concerns/api/v2/move_payload/text_fields.rb`
  - `app/controllers/concerns/api/v2/move_payload/meta_fields.rb`
- Updated `MoveDetailPayload` to compose these modules while keeping the same external interface and response contract.
- Re-validated behavior with existing integration tests and RuboCop.

Implemented (target #3):
- Split v3 include loaders by domain and composed from root concern:
  - `app/controllers/concerns/api/v3/include_loaders/pokemon_loaders.rb`
  - `app/controllers/concerns/api/v3/include_loaders/relation_loaders.rb`
  - `app/controllers/concerns/api/v3/include_loaders/item_loaders.rb`
  - `app/controllers/concerns/api/v3/include_loaders/location_loaders.rb`
- Reduced `app/controllers/concerns/api/v3/include_loaders.rb` to composition + shared URL helper methods.
- Re-validated with focused v3 integration tests and RuboCop.

Implemented (target #4):
- Replaced string-based special-name filters with Arel `ILIKE` expressions:
  - `app/controllers/api/v3/contest_effect_controller.rb`
  - `app/controllers/api/v3/machine_controller.rb`
- Replaced raw join SQL with association join in:
  - `app/controllers/api/v3/evolution_chain_controller.rb`
- Re-validated with focused v3 integration tests and RuboCop.

Implemented (target #5):
- Replaced broad rescue in parity fetch path with explicit expected exception classes in:
  - `lib/pokeapi/parity/response_diff.rb`
- Added `RedirectError` for redirect-related transport failures so they stay in structured parity output.
- Left unexpected exceptions unrescued so regressions surface instead of being silently converted to status `0`.
- Added tests in:
  - `test/lib/pokeapi/parity/response_diff_test.rb`

Implemented (target #6):
- Added query-budget regression assertions (`X-Query-Count`) for include-heavy list/detail paths in:
  - `test/integration/api/v3/move_controller_test.rb`
  - `test/integration/api/v3/ability_controller_test.rb`
  - `test/integration/api/v3/type_controller_test.rb`
  - `test/integration/api/v3/item_attribute_controller_test.rb`
- Added shared test support helpers and reused them across integration tests:
  - `test/support/integration_query_assertions.rb`
  - `test/support/env_helpers.rb`
  - `test/support/sql_capture_helpers.rb`
- Centralized repeated assertion/helper logic:
  - `assert_query_count_at_most`
  - `assert_observability_headers`
  - `assert_not_found_error_envelope`
  - `assert_invalid_query_error`
  - `with_env`
  - `capture_select_queries` and `capture_select_query_count`
