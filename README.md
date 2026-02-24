# PokeAPI Rails

`pokeapi-rails` is a Rails implementation of the [PokeAPI](https://pokeapi.co) platform.

It keeps `/api/v2` behavior compatible with the existing ecosystem while building and stabilizing a normalized `/api/v3` surface with stronger contracts and performance checks.

## Why This Project?

This project exists as a **modern Rails implementation** of the Pokemon API platform. While the original PokeAPI serves static data perfectly, a Rails implementation offers:

- **Deployment flexibility**: Self-host with full control over infrastructure
- **Extensibility**: Add authentication, custom endpoints, or integrate with other services
- **Monitoring & observability**: Built-in rate limiting, logging, and performance tracking
- **Learning & customization**: Study or modify the architecture to fit your needs
- **Modern patterns**: Field selection, filtering, sorting, and pagination (v3 API)

This isn't meant to replace the original PokeAPI—it's an alternative implementation that can be deployed, extended, and customized for your specific requirements.

## API Versions

### `/api/v2`
- Stable, production-ready API compatible with the existing PokeAPI ecosystem
- Full response payloads with all nested data
- Includes resources like Pokemon, Moves, Items, Abilities, and more

### `/api/v3` (Experimental)
- Normalized API with stronger contracts and performance checks
- **Field selection**: Request only the fields you need
- **Resource inclusion**: Expand nested relationships on demand
- **Query filtering**: Filter by specific fields
- **Sorting**: Customize result ordering
- **Pagination**: Control result set size

The v3 version allows testing improved API patterns before making breaking changes. Eventually, v3 may replace v2 internally after it stabilizes.

## Quality & Security

- ✅ **168 test files** covering integration, model, and service tests
- ✅ **CI pipeline** with security scanning (Brakeman, Bundler-audit)
- ✅ **Code quality checks** via RuboCop
- ✅ **OpenAPI contract validation** for v3 endpoints
- ✅ **0 critical security issues** (verified via automated analysis)
- ✅ **N+1 query detection** via Prosopite
- ✅ **Rate limiting** via Rack::Attack with burst protection
- ✅ **Structured logging** with request observability

## Docs

- Plan: [`docs/rails-adoption-plan.md`](docs/rails-adoption-plan.md)
- Implementation status: [`docs/implementation-status.md`](docs/implementation-status.md)
- Recent changes timeline: [`docs/recent-changes.md`](docs/recent-changes.md)
- Next targets: [`docs/next-targets.md`](docs/next-targets.md)
- Model association audit: [`docs/model-association-audit.md`](docs/model-association-audit.md)
- Import guide: [`docs/importing.md`](docs/importing.md)
- Logging guide: [`docs/logging.md`](docs/logging.md)
- Parity diff guide: [`docs/parity-diff.md`](docs/parity-diff.md)
- Deployment guide: [`docs/deployment.md`](docs/deployment.md)

## Tech Stack

- **Rails 8** - Latest framework version with modern conventions
- **PostgreSQL** - Production-ready database with full relationship support
- **Puma** - Concurrent web server
- **OJ** - Fast JSON parser
- **Prosopite** - N+1 query detection
- **Rack::Attack** - Rate limiting and request throttling
- **Docker** - Container-based deployment
- **Railway** - Cloud deployment platform (optional)

## License

See [LICENSE](./LICENSE)

## Thanks

- Thanks to Codex for implementation support, debugging help, and migration iteration assistance.
