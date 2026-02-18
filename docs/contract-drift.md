# Contract Drift Check

Use this task to compare source OpenAPI operations against Rails `/api/v2` routes.

## Command

```bash
bin/rails pokeapi:contract:drift
```

Defaults:

- `SOURCE_OPENAPI_PATH=../pokeapi/openapi.yml` (resolved from this repo root)
- `MAX_ITEMS=200` (max printed operations per mismatch section)

## Optional Environment Variables

```bash
SOURCE_OPENAPI_PATH=~/Desktop/Tries/pokeapi/openapi.yml bin/rails pokeapi:contract:drift
MAX_ITEMS=50 bin/rails pokeapi:contract:drift
OUTPUT_FORMAT=json bin/rails pokeapi:contract:drift
```

## Output Meaning

- `Missing in Rails`: operation exists in source OpenAPI, but not in Rails routes.
- `Extra in Rails`: operation exists in Rails routes, but not in source OpenAPI.

If any mismatch exists, task exits with an error.
