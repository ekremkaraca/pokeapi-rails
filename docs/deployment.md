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
