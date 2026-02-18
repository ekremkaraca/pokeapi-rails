# Next Target

This file is the single checkpoint for where to continue work next.

## Current State

- `/api/v2` router resource coverage is complete (48/48 source resources).
- Import pipeline is stable via `bin/rails pokeapi:import:all`.
- Optional skip mode exists for unchanged CSVs: `POKEAPI_SKIP_UNCHANGED=1`.
- CSV default source path is in-repo: `db/data/v2/csv`.
- Lightweight parity task exists: `bin/rails pokeapi:parity:diff`.
- Parity task supports machine-readable output: `OUTPUT_FORMAT=json`.
- Parity profiles are implemented: `smoke`, `core`, `full`.
- Core parity is currently green: `PATH_PROFILE=core` -> `20 passed, 0 failed`.
- Major rich endpoints now read from DB-backed relation tables (including `pokemon`, `pokemon/:id/encounters`, and `move`).
- Contract drift checker exists: `bin/rails pokeapi:contract:drift` (source OpenAPI vs Rails routes).
- Contract drift task supports machine-readable output: `OUTPUT_FORMAT=json`.
- CI workflow includes API contract/parity job (import smoke + import all + `core` parity + contract drift).

## Next Target (Primary)

Improve contract-level parity reporting and automation.

Goal:
- Keep OpenAPI contract drift checks easy to run in local/CI flows.
- Preserve core response parity while expanding reporting depth.
- Improve visibility into mismatch hotspots by endpoint.

## Task Breakdown

1. Add contract drift docs and usage conventions
- Document `SOURCE_OPENAPI_PATH` defaults and examples.
- Document failure interpretation for missing vs extra operations.

2. Add machine-readable reporting output
- Add JSON output option for parity and contract drift tasks.
- Include summary counts + full mismatch lists for CI artifacts.

3. Expand parity reporting detail
- Add grouped summary by endpoint for JSON output.
- Keep text output concise for local iteration.

4. Add tests
- Add/expand tests for new reporting output modes.
- Keep existing profile and diff behavior unchanged.

## Validation

Run after changes:

```bash
bin/rails test test/integration/api/v2/pokemon_controller_test.rb
bin/rails test test/integration/api/v2/move_controller_test.rb
bin/rails -T pokeapi:import
PATH_PROFILE=core bin/rails pokeapi:parity:diff
bin/rails pokeapi:contract:drift
```

If using non-default hosts:

```bash
RAILS_BASE_URL=http://localhost:3000 SOURCE_BASE_URL=http://localhost:8000 bin/rails pokeapi:parity:diff
```

## After This Target

- Expand `full` profile path coverage with at least one curated high-cardinality detail endpoint per resource family.
- Add fast-path CI variant (smoke parity + contract drift only) to reduce runtime on non-main branches.
