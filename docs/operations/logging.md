# Logging Guide

This project uses a gem-free structured request logger for readable, low-noise logs in all environments.

## Overview

Request logs are emitted as one JSON line per request from:

- `config/initializers/request_logging.rb`
- `lib/pokeapi/logging/request_event.rb`

The logger subscribes to `process_action.action_controller` notifications and builds a compact request event.

## What It Changes

- Replaces noisy multi-line controller/view request logs with compact JSON events.
- Normalizes `path` to exclude query string.
- Exposes `query_keys` instead of full query text.
- Adds `query_count` and `response_bytes` when available from response headers.
- Logs slow requests at `warn` level.
- Adds optional sampling for high-volume successful requests.
- Supports suppression of noisy known 404 scanner/static-miss paths.
- Keeps request context:
  - `request_id`
  - `method`
  - `path`
  - `status`
  - `controller`, `action`, `format`
  - `duration_ms`, `db_ms`, `view_ms`
  - `host`, `remote_ip`, `client_ip`
  - `ua_sha1` (SHA1 fingerprint of user-agent, not raw UA)

## Environment Toggles

All toggles are optional.

- `SIMPLE_REQUEST_LOGS`
  - Default: enabled
  - Set `SIMPLE_REQUEST_LOGS=0` to disable this custom logger.

- `SIMPLE_REQUEST_SLOW_MS`
  - Default: `500`
  - Requests with `duration_ms >= SIMPLE_REQUEST_SLOW_MS` are logged with `warn` instead of `info`.

- `SIMPLE_REQUEST_SUPPRESS_404_NOISE`
  - Default: `1` (enabled)
  - Suppresses 404 events from fallback `ErrorsController` for common probe/static-miss patterns:
    - `/assets/...`
    - `/.git...`
    - `*.php`
    - `/server-status`
    - `/server-info`
    - `/graphql` (when unmatched and routed to fallback)

- `SIMPLE_REQUEST_SAMPLE_RATE`
  - Default: `1.0` (no sampling)
  - Range: `0.0..1.0`
  - Applies only to non-slow, successful events (`status < 400`).
  - Slow/error events are always logged.

## Event Shape

Example:

```json
{
  "event": "request",
  "request_id": "abc-123",
  "method": "GET",
  "path": "/api/v3/pokemon",
  "query_keys": ["limit", "offset"],
  "status": 200,
  "controller": "Api::V3::PokemonController",
  "action": "index",
  "format": "json",
  "host": "pokeapi.ekrem.dev",
  "remote_ip": "203.0.113.10",
  "client_ip": "198.51.100.20",
  "ua_sha1": "f2a5...",
  "duration_ms": 43.79,
  "slow": false,
  "slow_threshold_ms": 500.0,
  "db_ms": 40.01,
  "view_ms": 0.14,
  "query_count": 4,
  "response_bytes": 1234
}
```

Notes:

- `params` may be omitted for noisy 404 fallback events.
- `query_keys` appears only when query params exist.
- `exception_class` appears when an exception is present.

## Why `ua_sha1` Instead of Raw UA

- Keeps logs concise and less noisy.
- Still allows grouping similar traffic sources.
- Reduces raw payload retention from scanner traffic.

## Operational Recommendations

- Keep `SIMPLE_REQUEST_SUPPRESS_404_NOISE=1` in production to reduce egress/log cost from scan noise.
- Tune `SIMPLE_REQUEST_SLOW_MS` based on your SLO (for example, 300–700ms).
- Use `SIMPLE_REQUEST_SAMPLE_RATE` (for example `0.25`) if log volume is still high.
- For incident debugging, temporarily set:
  - `SIMPLE_REQUEST_SUPPRESS_404_NOISE=0` to see all 404 fallback events.
  - `SIMPLE_REQUEST_SAMPLE_RATE=1.0` to disable sampling temporarily.

## Rollback

To revert to default Rails logging quickly:

1. Set `SIMPLE_REQUEST_LOGS=0`
2. Restart the app

No code rollback is required for emergency disable.

## Tests

Formatter behavior is covered by:

- `test/lib/pokeapi/logging/request_event_test.rb`
