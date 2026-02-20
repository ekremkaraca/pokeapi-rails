# Contract Checks

This project has separate contract checks for `/api/v2` and `/api/v3`.

## `/api/v2` Drift Check

```bash
bin/rails pokeapi:contract:drift
```

Defaults:

- `SOURCE_OPENAPI_PATH=../pokeapi/openapi.yml` (resolved from this repo root)
- `MAX_ITEMS=200` (max printed operations per mismatch section)

Optional environment variables:

```bash
SOURCE_OPENAPI_PATH=~/Desktop/Tries/pokeapi/openapi.yml bin/rails pokeapi:contract:drift
MAX_ITEMS=50 bin/rails pokeapi:contract:drift
OUTPUT_FORMAT=json bin/rails pokeapi:contract:drift
```

Output meaning:

- `Missing in Rails`: operation exists in source OpenAPI, but not in Rails routes.
- `Extra in Rails`: operation exists in Rails routes, but not in source OpenAPI.

If any mismatch exists, task exits with an error.

## `/api/v3` OpenAPI Structure Validation

Validates OpenAPI file structure/rules for v3 docs.

```bash
bin/rails pokeapi:contract:validate_v3_openapi
```

Optional:

```bash
V3_OPENAPI_PATH=public/openapi-v3.yml bin/rails pokeapi:contract:validate_v3_openapi
```

## `/api/v3` Drift Check

Compares v3 OpenAPI operations against Rails `/api/v3` routes.

```bash
bin/rails pokeapi:contract:drift_v3
```

Optional:

```bash
V3_OPENAPI_PATH=public/openapi-v3.yml bin/rails pokeapi:contract:drift_v3
MAX_ITEMS=50 bin/rails pokeapi:contract:drift_v3
OUTPUT_FORMAT=json bin/rails pokeapi:contract:drift_v3
```

If any mismatch exists, task exits with an error.

## `/api/v3` Budget Check

Checks pilot endpoint budgets using runtime observability headers:

- `X-Query-Count`
- `X-Response-Time-Ms`

```bash
bin/rails pokeapi:contract:check_v3_budgets
```

JSON output:

```bash
OUTPUT_FORMAT=json bin/rails pokeapi:contract:check_v3_budgets
```

Useful threshold overrides:

- `V3_BUDGET_LIST_QUERY_MAX`
- `V3_BUDGET_LIST_RESPONSE_MS_MAX`
- `V3_BUDGET_DETAIL_QUERY_MAX`
- `V3_BUDGET_DETAIL_RESPONSE_MS_MAX`
- `V3_BUDGET_LIST_INCLUDE_QUERY_MAX`
- `V3_BUDGET_LIST_INCLUDE_RESPONSE_MS_MAX`
- `V3_BUDGET_DETAIL_INCLUDE_QUERY_MAX`
- `V3_BUDGET_DETAIL_INCLUDE_RESPONSE_MS_MAX`

If any scenario breaches a threshold (or misses required headers), task exits with an error.

## CI Usage

Current CI checks include:

- `pokeapi:contract:validate_v3_openapi`
- `pokeapi:contract:drift_v3`
- `pokeapi:contract:check_v3_budgets` (JSON artifact)
