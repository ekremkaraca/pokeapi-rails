# /api/v3 RFC

## Status
- Proposed
- Owner: `pokeapi-rails` maintainers
- Scope: New `/api/v3` REST surface; `/api/v2` remains frozen and supported

## Why v3
- `/api/v2` parity is now stable and contract-safe.
- Existing payloads are large and inconsistent across resources.
- We need better client ergonomics, performance controls, and clearer contracts without breaking v2 users.

## Goals
1. Keep `/api/v2` unchanged and backward compatible.
2. Deliver a cleaner and more consistent API contract in `/api/v3`.
3. Improve response efficiency and observability by default.
4. Make contract drift and parity checks first-class CI signals.

## Non-Goals
- No breaking changes in `/api/v2`.
- No full rewrite of import/storage pipeline before v3 launch.
- No immediate GraphQL replacement in this RFC.

## Design Principles
- Consistency over endpoint-specific exceptions.
- Explicitness over implicit payload expansion.
- Performance controls built into the contract.
- Spec-first development with OpenAPI as the source of truth.

## Priority Backlog

### Must
1. Versioning and compatibility policy
- `/api/v3` is opt-in.
- `/api/v2` freeze policy documented.
- Deprecation policy for future v3 changes documented.

2. Standard response conventions
- Uniform list envelope and pagination metadata.
- Uniform resource reference format (`id`, `name`, `url`) where applicable.
- Uniform error envelope (`code`, `message`, `details`, `request_id`).

3. Query/payload controls
- Standardized filtering/sorting query conventions.
- Sparse fields (`fields=`) and include expansion (`include=`) with explicit allowlists.
- Safe defaults for payload size.

4. Contract and testing
- OpenAPI for `/api/v3` committed in repo.
- Contract drift check in CI against implementation.
- Request/integration coverage for all v3 endpoints added in each rollout slice.

5. Baseline performance/caching
- `ETag` and conditional GET support for list/detail.
- Documented target query budgets for high-cardinality endpoints.

### Should
1. Cursor pagination for high-cardinality resources.
2. Endpoint-level performance telemetry (latency, query count, error rate).
3. Stable enum/value documentation in OpenAPI.
4. Better search semantics (alias/name ranking) for name-based lookups.
5. JSON output reports for parity/contract checks published as CI artifacts.

### Could
1. Bulk endpoints for common client batching patterns.
2. Partial embedding profiles (e.g., `view=compact|full`).
3. Client SDK generation pipeline from OpenAPI.
4. Usage analytics and endpoint adoption dashboard by API version.

## Proposed /api/v3 Conventions

### List responses
```json
{
  "count": 1302,
  "next": "...",
  "previous": "...",
  "results": []
}
```

### Error responses
```json
{
  "error": {
    "code": "not_found",
    "message": "Resource not found",
    "details": {},
    "request_id": "..."
  }
}
```

### Query conventions (initial)
- Pagination: `limit`, `offset` (cursor where enabled)
- Filtering: `filter[field]=value`
- Sorting: `sort=field,-other_field`
- Field selection: `fields=...`
- Expansion: `include=...`

## Phased Rollout Plan

## Phase 0: RFC + Contract Skeleton
Deliverables:
- This RFC approved.
- `/api/v3` OpenAPI skeleton (style guide + shared schemas + error model).
- Linting rules for query parameter conventions.

Exit criteria:
- Team alignment on must backlog and rollout gates.

## Phase 1: Foundation
Deliverables:
- `/api/v3` routing namespace.
- Shared controller concern for standardized errors/pagination/filter/sort parsing.
- Request ID propagation in error envelope.
- Base contract tests + OpenAPI validation in CI.

Exit criteria:
- One sample resource demonstrates v3 conventions end-to-end.

## Phase 2: Pilot Resource Slice
Target resources:
- `pokemon`, `ability`, `type` (list + detail)

Deliverables:
- v3 endpoints with sparse fields/include controls.
- Caching headers + query budget checks.
- Migration notes from v2 shape to v3 shape.

Exit criteria:
- Pilot endpoints stable and passing contract/perf checks.

## Phase 3: Expanded Coverage
Target:
- Remaining high-traffic resources (`move`, `item`, `pokemon-species`, etc.)

Deliverables:
- Incremental rollout by resource family.
- Cursor pagination where data size warrants.
- Per-endpoint observability dashboards.

Exit criteria:
- Top traffic resources available in v3 with docs/tests.

## Phase 4: Public Adoption
Deliverables:
- v3 documentation site section + migration guide.
- Client guidance for v2 -> v3 field/query mapping.
- Adoption metrics and SLO tracking.

Exit criteria:
- Defined percentage of traffic or clients using v3 successfully.

## Phase 5: Long-Term Governance
Deliverables:
- Ongoing version governance process.
- Scheduled contract review cadence.
- Backward-compatibility test matrix for all active versions.

Exit criteria:
- Stable release process for future v3 iterations.

## Acceptance Criteria (Must Gate)
- No `/api/v2` contract regressions.
- v3 OpenAPI and implementation remain drift-free in CI.
- Core v3 resources meet documented response-time/query-budget targets.
- All must-priority items completed before public recommendation of v3.

## Risks and Mitigations
1. Scope creep in v3 schema redesign
- Mitigation: enforce must/should/could boundaries per phase.

2. Inconsistent endpoint behavior during migration
- Mitigation: shared concerns + request spec contract suite.

3. Performance regressions from richer query features
- Mitigation: allowlist-based includes/fields and endpoint query budgets.

4. Client confusion across versions
- Mitigation: strict docs/migration tables and explicit changelog policy.

## Immediate Next Actions
1. Approve this RFC and lock must list.
2. Add `/api/v3` OpenAPI skeleton file and CI validation.
3. Implement Phase 1 foundation with one pilot endpoint.
