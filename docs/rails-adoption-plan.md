# PokeAPI Django -> Rails Adoption Plan

## Purpose
This document is the reference plan for adopting the Python/Django PokeAPI implementation (`~/Desktop/Tries/pokeapi`) into this Rails application (`~/Desktop/Tries/pokeapi-rails`) while preserving API behavior and response compatibility for `/api/v2`.

## Current Baseline
- Source app: Django + DRF (`pokemon_v2`)
- Target app: Rails API implementation with broad `/api/v2` coverage and importer/test infrastructure in place
- Source REST scope: 48 router resources + 1 custom encounters route
- OpenAPI paths in source: 97 (`/api/v2/*` list + detail + custom route)
- Data build approach: CSV-driven loader (`data/v2/build.py`)
- Data volume snapshot:
  - CSV: ~36 MB (`data/v2/csv`, 178 files)
  - Sprites: ~1.7 GB
  - Cries: ~28 MB
  - SQLite snapshot: ~92 MB

## Migration Goals
1. Preserve public API contract for `/api/v2`.
2. Preserve behavior details used by clients:
   - retrieve by numeric ID or by name
   - `q` name filter on list endpoints
   - limit/offset pagination behavior
   - summary vs detail output shape
   - special route `/api/v2/pokemon/{id}/encounters`
3. Replace Django runtime with Rails while keeping dataset quality and update workflow.

## Non-Goals (Initial Cut)
- Rebuilding GraphQL/Hasura stack in phase 1
- Re-hosting all media assets locally in phase 1
- Redesigning API shape or introducing breaking changes

## Guiding Principles
- Contract-first: `openapi.yml` from source is the baseline until Rails parity is proven.
- Vertical slices over big-bang migration.
- Deterministic imports (IDs and relationships must match source behavior).
- Compatibility before optimization.

## Phased Execution Plan

## Phase 0: Contract Freeze and Inventory
Deliverables:
- Endpoint matrix from source OpenAPI and router declarations.
- Behavior matrix per endpoint (filters, pagination, lookup semantics, edge cases).
- Field parity mapping for list/detail serializers.

Tasks:
- Extract route list from `pokemon_v2/urls.py`.
- Extract serializer fields from `pokemon_v2/serializers.py`.
- Mark custom behaviors in `pokemon_v2/api.py`.

Exit criteria:
- We can answer: "what exactly must Rails return for each endpoint?"

## Phase 1: Rails API Foundation
Deliverables:
- `/api/v2` namespace and base API controller.
- Shared error envelope and 404 handling matching source behavior.
- Shared concerns for:
  - ID-or-name lookup
  - `q` filter
  - limit/offset pagination
- Basic request spec harness.

Tasks:
- Configure API-oriented controller stack.
- Add serialization strategy (single approach across all resources).
- Implement shared concerns and test them in isolation.

Exit criteria:
- A dummy resource demonstrates matching list/retrieve semantics.

## Phase 2: Data Model and Import Pipeline
Deliverables:
- Initial Rails schema for first vertical slice.
- Rake task equivalent to source `build-db` flow.
- Deterministic CSV import with FK-safe ordering and batched inserts.

Tasks:
- Port core tables for first slice.
- Implement import services per CSV domain group.
- Keep source IDs instead of re-sequencing.
- Add import logging and failure diagnostics.

Exit criteria:
- First slice data can be rebuilt from CSV into Postgres repeatably.

## Phase 3: Vertical Slice A (Core Pokemon)
Target endpoints:
- `pokemon`
- `pokemon-species`
- `type`
- `ability`
- `pokemon/{id}/encounters`

Deliverables:
- Models, controllers, serializers, request specs.
- Parity checks against source responses for sampled IDs/names.

Exit criteria:
- Slice A endpoints are contract-compatible for key sampled cases.

## Phase 4: Vertical Slice B (Moves, Items, Locations)
Target endpoints include:
- `move*`
- `item*`
- `location*`
- related lookup/reference resources

Deliverables:
- Expanded schema + importers + API resources + tests.

Exit criteria:
- Slice B parity tests green and performance acceptable.

## Phase 5: Vertical Slice C (Remaining Resources)
Target:
- Remaining metadata/utility resources (`version*`, `generation`, `nature`, etc.)

Deliverables:
- Full `/api/v2` coverage in Rails.

Exit criteria:
- All source REST endpoints implemented and tested in Rails.

## Phase 6: Parity Verification and Hardening
Deliverables:
- Automated diff harness (sampled response comparison: Django vs Rails).
- OpenAPI generation and diff report.
- Performance baseline report.

Tasks:
- Compare response JSON for representative fixtures (IDs, names, list pages).
- Verify edge cases (invalid IDs, invalid names, extreme limits, missing records).
- Add indexes tuned for hot endpoints.

Exit criteria:
- No high-severity contract diffs.

## Phase 7: Release and Cutover
Deliverables:
- Parallel run plan.
- Canary rollout and monitoring dashboard.
- Rollback strategy.

Tasks:
- Route a subset of traffic to Rails.
- Monitor p95 latency, error rate, and response diff alarms.
- Expand traffic once stable.

Exit criteria:
- Rails serves 100% of `/api/v2` traffic within SLO.

## Technical Design Decisions (Proposed)
- Database: Postgres for target runtime.
- Import style: batched `insert_all`/bulk operations with explicit transaction boundaries.
- API format: stable JSON shape matching source, not JSON:API.
- Asset strategy (phase 1): keep URL references to existing sprite/cry repositories.
- Test strategy:
  - request specs for endpoint behavior
  - import tests for CSV correctness
  - parity snapshots for sampled outputs

## Key Risks and Mitigations
1. Response drift (field names/nullability/nesting)
- Mitigation: contract tests + parity diff harness before release.

2. Import correctness for relational graph
- Mitigation: deterministic load order + FK validation checks + row-count assertions.

3. Performance regressions on large list/detail joins
- Mitigation: endpoint-level query profiling, selective eager loading, targeted indexes.

4. Hidden Django behavior dependencies
- Mitigation: codify shared behaviors first (lookup/filter/pagination) and test globally.

5. Scope creep from full ecosystem migration (GraphQL, infra extras)
- Mitigation: keep REST parity as phase-1 success criterion.

## Milestones and Success Criteria
Milestone 1:
- Rails foundation + shared behavior concerns complete.

Milestone 2:
- Slice A endpoints live with parity tests.

Milestone 3:
- Full `/api/v2` endpoint coverage.

Milestone 4:
- Production cutover complete.

Definition of done:
- All `/api/v2` endpoints available in Rails.
- Contract compatibility proven by tests/diff checks.
- Data rebuild command documented and repeatable.
- Operational dashboards and rollback path in place.

## Immediate Next Steps
1. Expand parity sample coverage (move from a small fixed sample set toward one list/detail case per resource).
2. Add response-shape checks for richer relational detail fields where Rails currently returns simplified payloads.
3. Add automated OpenAPI diff reporting between source and Rails-generated contract output.
4. Add targeted indexing/perf checks based on parity sample hot paths.

## Reference Source Files
- `~/Desktop/Tries/pokeapi/pokemon_v2/urls.py`
- `~/Desktop/Tries/pokeapi/pokemon_v2/api.py`
- `~/Desktop/Tries/pokeapi/pokemon_v2/serializers.py`
- `~/Desktop/Tries/pokeapi/data/v2/build.py`
- `~/Desktop/Tries/pokeapi/openapi.yml`
