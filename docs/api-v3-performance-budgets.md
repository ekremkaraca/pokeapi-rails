# /api/v3 Performance and Query Budgets

This document defines baseline targets for currently implemented `/api/v3` resources.
Resource coverage now mirrors all `/api/v2` list/detail resources currently implemented in this repo.

## Target Budgets

Budgets are per request in local parity-like conditions (warm DB/cache, representative dataset).

- List endpoints (`/api/v3/{resource}`):
  - Query count: <= 8
  - p95 response time: <= 150ms
- Detail endpoints (`/api/v3/{resource}/{id}`):
  - Query count: <= 6
  - p95 response time: <= 120ms

With include expansions:

- List with include:
  - Query count: <= 12
  - p95 response time: <= 220ms
- Detail with include:
  - Query count: <= 10
  - p95 response time: <= 180ms

## Scope Notes

- Targets are initial governance thresholds, not final SLOs.
- If a change exceeds a budget, PR should include:
  - reason
  - impact estimate
  - follow-up optimization plan

## Measurement Approach

- Use integration tests and request profiling in development.
- Compare before/after query counts and timing for:
  - baseline list/detail
  - list/detail with `include`
  - representative `fields`/`sort` combinations

### Runnable Budget Check Task

Use the built-in checker:

```bash
bin/rails pokeapi:contract:check_v3_budgets
```

JSON output:

```bash
OUTPUT_FORMAT=json bin/rails pokeapi:contract:check_v3_budgets
```

Threshold overrides:

- `V3_BUDGET_LIST_QUERY_MAX` (default: `8`)
- `V3_BUDGET_LIST_RESPONSE_MS_MAX` (default: `150`)
- `V3_BUDGET_DETAIL_QUERY_MAX` (default: `6`)
- `V3_BUDGET_DETAIL_RESPONSE_MS_MAX` (default: `120`)
- `V3_BUDGET_LIST_INCLUDE_QUERY_MAX` (default: `12`)
- `V3_BUDGET_LIST_INCLUDE_RESPONSE_MS_MAX` (default: `220`)
- `V3_BUDGET_DETAIL_INCLUDE_QUERY_MAX` (default: `10`)
- `V3_BUDGET_DETAIL_INCLUDE_RESPONSE_MS_MAX` (default: `180`)

## Caching Expectations

- All v3 list/detail endpoints should emit `ETag`.
- Conditional requests with matching `If-None-Match` should return `304`.
- Any cache key change must preserve representation correctness across:
  - `limit`, `offset`, `q`, `sort`, `fields`, `include`

## Exit Criteria for Public Recommendation

- Budgets consistently met for current v3 resources.
- Regressions are blocked or explicitly accepted with tracking issue.
