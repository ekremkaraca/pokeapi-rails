# Completed Targets

This file archives completed target sets and implementation history moved out of `docs/planning/next-targets.md`.

## Completed Set: Association + Include Refactor Cycle

Status: completed.

### Merge Readiness Summary

- [x] Target #1: Placeholder prose sanitization at import time + importer tests.
- [x] Target #2: `v2/move_controller` decomposition into focused payload concerns.
- [x] Target #3: `v3/include_loaders` split into domain sub-concerns.
- [x] Target #4: SQL/string-query hardening in selected v3 controllers.
- [x] Target #5: Parity tooling rescue narrowed to expected fetch errors.
- [x] Target #6: Include-heavy v3 query-budget regression coverage added.
- [x] Target #7: Shared test-helper/assertion consolidation across suites.

### Completed Production Log Checklist (2026-02-24)

- [x] 1. Optimize slow `/api/v2` hot paths.
- [x] 2. Fix observability metric consistency (`db_ms > duration_ms`).
- [x] 3. Reduce root-path 406 noise.
- [x] 4. Ensure real client IP visibility for logs/throttling.
- [x] 5. Reduce crawler noise for `/sitemap.xml`.
- [x] 6. Tune `/api/v3/pokemon/:id` tail latency.

### Implementation Notes (Condensed)

- Added placeholder prose sanitizer and importer coverage:
  - `app/services/pokeapi/importers/item_prose_importer.rb`
  - `app/services/pokeapi/importers/move_effect_prose_importer.rb`
  - `test/services/pokeapi/importers/item_prose_importer_test.rb`
  - `test/services/pokeapi/importers/move_effect_prose_importer_test.rb`

- Refactored v2 move payload composition:
  - `app/controllers/concerns/api/v2/move_detail_payload.rb`
  - `app/controllers/concerns/api/v2/move_payload/relation_fields.rb`
  - `app/controllers/concerns/api/v2/move_payload/text_fields.rb`
  - `app/controllers/concerns/api/v2/move_payload/meta_fields.rb`

- Split v3 include loaders into domain concerns:
  - `app/controllers/concerns/api/v3/include_loaders/pokemon_loaders.rb`
  - `app/controllers/concerns/api/v3/include_loaders/relation_loaders.rb`
  - `app/controllers/concerns/api/v3/include_loaders/item_loaders.rb`
  - `app/controllers/concerns/api/v3/include_loaders/location_loaders.rb`

- Hardened SQL/query maintenance points:
  - `app/controllers/api/v3/contest_effect_controller.rb`
  - `app/controllers/api/v3/machine_controller.rb`
  - `app/controllers/api/v3/evolution_chain_controller.rb`

- Narrowed parity fetch rescue scope and added tests:
  - `lib/pokeapi/parity/response_diff.rb`
  - `test/lib/pokeapi/parity/response_diff_test.rb`

- Expanded include-heavy v3 query-budget regression coverage:
  - `test/integration/api/v3/move_controller_test.rb`
  - `test/integration/api/v3/ability_controller_test.rb`
  - `test/integration/api/v3/type_controller_test.rb`
  - `test/integration/api/v3/item_attribute_controller_test.rb`

- Consolidated shared test helpers:
  - `test/support/integration_query_assertions.rb`
  - `test/support/env_helpers.rb`
  - `test/support/sql_capture_helpers.rb`

For detailed timeline context, see `docs/planning/recent-changes.md`.
