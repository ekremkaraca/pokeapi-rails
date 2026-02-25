# Parity Diff Harness

Use the parity diff task to compare sampled `/api/v2` responses between this Rails app and a source API (typically Django PokeAPI).

## Command

```bash
bin/rails pokeapi:parity:diff
```

Defaults:

- `RAILS_BASE_URL=http://localhost:3000`
- `SOURCE_BASE_URL=http://localhost:8000`
- `PATH_PROFILE=smoke`
- Sample paths are selected from profiles in `Pokeapi::Parity::ResponseDiff`

## Path Profiles

Profiles let you choose speed vs coverage.

- `smoke`: quickest sanity check
- `core`: broad parity checks across key list/detail paths
- `full`: widest local coverage (slowest)

Example:

```bash
PATH_PROFILE=core bin/rails pokeapi:parity:diff
```

## Override Paths Directly

Provide a comma-separated list:

```bash
PATHS="/api/v2/,/api/v2/pokemon/1/,/api/v2/move/1/" bin/rails pokeapi:parity:diff
```

When `PATHS` is provided, it takes precedence over profile defaults.

## Options

- `RAILS_BASE_URL` - Rails API base URL
- `SOURCE_BASE_URL` - source API base URL
- `PATH_PROFILE` - profile set (`smoke`, `core`, `full`)
- `PATHS` - comma-separated request paths to compare
- `MAX_DIFFS` - max diff lines printed per failing path (default `20`)
- `OUTPUT_FORMAT` - `text` (default) or `json`

JSON example:

```bash
PATH_PROFILE=core OUTPUT_FORMAT=json bin/rails pokeapi:parity:diff
```

## Output Format

Failures are grouped by endpoint, then by path.

- `status_mismatch`: different HTTP status between Rails and source
- `json_diff`: same status, but response JSON differs

The output is intentionally concise and prints first-N diffs (`MAX_DIFFS`) for quick iteration.

## Exit Behavior

- exits successfully if all sampled paths match
- raises an error if any status/body diffs are found

## URL and Slash Normalization Notes

The harness normalizes base URL differences so host/port mismatches do not create false positives.

It also handles trailing slash behavior robustly:

- Rails and source may redirect differently for some list paths
- parity compares final response payloads and normalized URLs

## Troubleshooting Checklist

If you see `rails=0` or connection errors:

1. Ensure both servers are running:
   - Rails on `RAILS_BASE_URL`
   - source API on `SOURCE_BASE_URL`
2. Verify both hosts are reachable:
   - `curl http://localhost:3000/api/v2/`
   - `curl http://localhost:8000/api/v2/`
3. Re-run with explicit env vars:

```bash
RAILS_BASE_URL=http://localhost:3000 SOURCE_BASE_URL=http://localhost:8000 PATH_PROFILE=core bin/rails pokeapi:parity:diff --trace
```

## Current Milestone

Latest local validation in this repository:

```text
PATH_PROFILE=core -> Compared 20 path(s): 20 passed, 0 failed
```
