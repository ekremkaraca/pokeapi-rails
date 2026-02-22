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
