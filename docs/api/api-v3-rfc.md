# /api/v3 RFC

## Status
- Proposed
- `/api/v3` is experimental and not yet recommended as the default public API.
- `/api/v2` is active, supported, and not deprecated.
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

## Progress Notes
- RFC Action #2 complete:
  - `/api/v3` OpenAPI skeleton added at `public/openapi-v3.yml`
  - validation task added: `bin/rails pokeapi:contract:validate_v3_openapi`
- Versioning/adoption docs added:
  - version/deprecation policy: `docs/api/api-versioning-policy.md`
  - pilot migration guide: `docs/api/api-v3-migration-guide.md`
  - pilot performance budgets: `docs/api/api-v3-performance-budgets.md`
  - v3 changelog: `docs/api/api-v3-changelog.md`
- Phase 1 pilot foundation started:
  - implemented `GET /api/v3/pokemon`
  - implemented `GET /api/v3/pokemon/{id}`
  - implemented `GET /api/v3/ability`
  - implemented `GET /api/v3/ability/{id}`
  - implemented `GET /api/v3/type`
  - implemented `GET /api/v3/type/{id}`
  - implemented conditional GET (`ETag` + `If-None-Match`) for v3 pilot list/detail endpoints
  - implemented allowlist-based sparse field selection via `fields=` for v3 pilot list/detail endpoints
  - implemented allowlist-based include parsing via `include=` (with `pokemon` support for `abilities`)
  - implemented allowlist-based include parsing via `include=` (with `ability` support for `pokemon`)
  - implemented allowlist-based include parsing via `include=` (with `type` support for `pokemon`)
  - implemented allowlist-based list sorting via `sort=` for v3 pilot resources
  - implemented allowlist-based list filtering via `filter[name]=value` for v3 pilot resources
  - documented `q` as legacy list search and defined `q` + `filter[name]` as AND semantics
  - added `/api/v3` OpenAPI-vs-routes drift check task: `bin/rails pokeapi:contract:drift_v3`
  - added `/api/v3` budget check task: `bin/rails pokeapi:contract:check_v3_budgets`
  - CI now runs `/api/v3` budget check and publishes JSON artifact
  - `/api/v3` now returns `X-API-Stability: experimental` header on all responses
  - `/api/v3` now returns `X-Query-Count` response header for lightweight query observability
  - `/api/v3` now returns `X-Response-Time-Ms` response header for lightweight latency observability
  - `/api/v3` OpenAPI documents `X-API-Stability: experimental` response headers
  - `/api/v3` OpenAPI documents `X-Query-Count` response headers
  - standardized v3 not-found envelope in `Api::V3::BaseController`
  - implemented `GET /api/v3/move`
  - implemented `GET /api/v3/move/{id}`
  - implemented `GET /api/v3/item`
  - implemented `GET /api/v3/item/{id}`
  - implemented `GET /api/v3/pokemon-species`
  - implemented `GET /api/v3/pokemon-species/{id}`
  - implemented `GET /api/v3/generation`
  - implemented `GET /api/v3/generation/{id}`
  - implemented `GET /api/v3/version-group`
  - implemented `GET /api/v3/version-group/{id}`
  - implemented `GET /api/v3/region`
  - implemented `GET /api/v3/region/{id}`
  - implemented `GET /api/v3/version`
  - implemented `GET /api/v3/version/{id}`
  - implemented `GET /api/v3/evolution-chain`
  - implemented `GET /api/v3/evolution-chain/{id}`
  - implemented `GET /api/v3/evolution-trigger`
  - implemented `GET /api/v3/evolution-trigger/{id}`
  - implemented `GET /api/v3/growth-rate`
  - implemented `GET /api/v3/growth-rate/{id}`
  - implemented `GET /api/v3/nature`
  - implemented `GET /api/v3/nature/{id}`
  - implemented `GET /api/v3/gender`
  - implemented `GET /api/v3/gender/{id}`
  - implemented `GET /api/v3/egg-group`
  - implemented `GET /api/v3/egg-group/{id}`
  - implemented `GET /api/v3/encounter-method`
  - implemented `GET /api/v3/encounter-method/{id}`
  - implemented `GET /api/v3/encounter-condition`
  - implemented `GET /api/v3/encounter-condition/{id}`
  - implemented `GET /api/v3/encounter-condition-value`
  - implemented `GET /api/v3/encounter-condition-value/{id}`
  - implemented `GET /api/v3/berry`
  - implemented `GET /api/v3/berry/{id}`
  - `/api/v3` root endpoint now includes `move` and `item` collections
  - `/api/v3` root endpoint now includes `generation`, `version-group`, `region`, `version`, and `pokemon-species` collections
  - `/api/v3` root endpoint now includes `evolution-chain`, `evolution-trigger`, `growth-rate`, `nature`, `gender`, `egg-group`, `encounter-method`, `encounter-condition`, `encounter-condition-value`, and `berry` collections
  - v3 budget check scenarios expanded to include `move`, `item`, `pokemon-species`, `generation`, `version-group`, `region`, `version`, `evolution-chain`, `evolution-trigger`, `growth-rate`, `nature`, `gender`, `egg-group`, `encounter-method`, `encounter-condition`, `encounter-condition-value`, and `berry` paths
  - v3 resource controllers refactored to reduce duplication using shared concern helpers for include-map loading and canonical URL generation
