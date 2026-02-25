# Deployment Guide

This project is deployed using a Dockerfile-based workflow.

## Railway

Required runtime environment variables:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `SECRET_KEY_BASE`

Optional Rack::Attack tuning:

- `RACK_ATTACK_ENABLED` (`true`/`false`, defaults to enabled in production)
- `RACK_ATTACK_API_LIMIT` (default: `300`)
- `RACK_ATTACK_API_PERIOD` in seconds (default: `300`)
- `RACK_ATTACK_API_BURST_LIMIT` (default: `60`)
- `RACK_ATTACK_API_BURST_PERIOD` in seconds (default: `60`)

API responses include informational limit headers:

- `X-RateLimit-Limit`
- `X-RateLimit-Period`
- `X-RateLimit-Burst-Limit`
- `X-RateLimit-Burst-Period`
- `X-RateLimit-Policy`

Optional request logging tuning:

- `SIMPLE_REQUEST_LOGS` (`1`/`0`, default enabled)
- `SIMPLE_REQUEST_SLOW_MS` (default: `500`)
- `SIMPLE_REQUEST_SUPPRESS_404_NOISE` (`1`/`0`, default enabled)
- `SIMPLE_REQUEST_SAMPLE_RATE` (`0.0..1.0`, default: `1.0`)

Optional v2 show-response cache tuning:

- `API_V2_SHOW_CACHE_TTL_SECONDS` (default: `60`)
- `API_V2_NAME_MISS_CACHE_TTL_SECONDS` (default: `15`)

Optional Puma process tuning:

- `WEB_CONCURRENCY`
  - `0` or unset: single-mode (recommended on small Railway instances)
  - `2+`: cluster mode with that worker count

Recommended production values:

- `SIMPLE_REQUEST_LOGS=1`
- `SIMPLE_REQUEST_SLOW_MS=500`
- `SIMPLE_REQUEST_SUPPRESS_404_NOISE=1`
- `SIMPLE_REQUEST_SAMPLE_RATE=1.0`
- `WEB_CONCURRENCY=0` (unless you intentionally run 2+ workers)

Recommended post-deploy commands (manual):

```bash
railway run bin/rails db:prepare
```

Optional data loading:

```bash
railway run bin/rails db:seed
railway run bin/rails pokeapi:import:all
```

## Notes

- Database setup is intentionally run as a manual one-off operation after deploy.
- Keep release operations explicit to avoid accidental migrations on web boot.
- For incident debugging, temporarily set:
  - `SIMPLE_REQUEST_SUPPRESS_404_NOISE=0` to view all fallback `404` probes.
  - `SIMPLE_REQUEST_SAMPLE_RATE=1.0` to disable sampling.
  - `SIMPLE_REQUEST_LOGS=0` to revert quickly to default Rails request logging.
