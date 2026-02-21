# Deployment Guide

This project is deployed using a Dockerfile-based workflow.

## Railway

Required runtime environment variables:

- `DATABASE_URL`
- `RAILS_MASTER_KEY`
- `SECRET_KEY_BASE`

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
