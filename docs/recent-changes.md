# Recent Changes

This file is a compact timeline of major updates made during the current migration and deployment hardening cycle.

## 2026-02-22

### Logging and request-noise reduction

- Added lightweight catch-all unknown-route handling through `ErrorsController#not_found` with minimal plain-text `404` payload.
- Added parameter filtering for GraphQL-style probe keys in logs:
  - `query`
  - `variables`
  - `operationName`
- Added gem-free structured request logging:
  - single JSON event per request
  - normalized path + `query_keys`
  - request context fields (`host`, `remote_ip`, `ua_sha1`)
  - slow-request warn threshold via env
  - optional suppression for common noisy 404 scanner/static-miss paths
- Added formatter tests in `test/lib/pokeapi/logging/request_event_test.rb`.
- Documented full logging behavior and env controls in `docs/logging.md`.

## 2026-02-21

### API behavior and stability

- Enforced JSON-only API behavior on namespaced API routes/controllers.
- Added `/favicon.ico` routing to avoid noisy API-browser routing errors.
- Normalized `/api/v3` include expansion URLs to always emit canonical `/api/v3/*` links.
- Refined include loaders to use association-backed eager loading in hot paths.
- Expanded include-loader normalization for v3 relation lookups across:
  - `pokemon/type`
  - `item/category`
  - `pokemon-species/generation`
  - `generation/main_region`
  - `version-group/generation`
  - `version/version_group`
  - `item-category/pocket`
  - `location/region`
  - `location-area/location`
  - `machine/item`
- Validated include-loader changes with targeted v3 integration suites:
  - `pokemon`, `type`, `item`, `pokemon-species`
  - `generation`, `version-group`, `version`
  - `location`, `location-area`, `machine`

### API protection and operations

- Added `rack-attack` throttling for `/api/*` endpoints with burst + sustained limits.
- Added user-visible response headers describing active throttle policy:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Period`
  - `X-RateLimit-Burst-Limit`
  - `X-RateLimit-Burst-Period`
  - `X-RateLimit-Policy`
- Documented production runtime requirements and one-off deploy commands for Railway.

### Docs and OpenAPI

- Replaced `rswag-ui`/`rswag-api` setup with `oas_rails`.
- Updated docs links and deployment guidance for public OpenAPI serving.
- Moved deployment runbook content from `README.md` into `docs/deployment.md`.

### CI and release workflow

- Removed heavy parity/budget checks from GitHub Actions CI to reduce recurring cost.
- Kept parity/contract budget checks available for local/manual release gates.

### Model and controller normalization

- Completed broad association normalization across FK-backed models.
- Added explicit `foreign_key` / `inverse_of` where naming is non-standard.
- Added/updated model associations for ability, pokemon, move, item, language, berry, region, type, and related graphs.
- Refactored selected controllers to use associations while preserving response payload shape.
- Documented audit details in `docs/model-association-audit.md`.

### Deployment hardening

- Resolved production boot issues related to:
  - `SECRET_KEY_BASE` / credentials setup
  - non-superuser extension creation conflicts on managed Postgres
  - optional Action Cable/solid-* runtime assumptions in production
- Kept migration/seed/import execution as explicit manual operations after deploy.

## Notes

- For active status and remaining release tasks, see `docs/implementation-status.md`.
- For migration planning context, see `docs/rails-adoption-plan.md`.
