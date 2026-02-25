# Architecture Decisions

This document records key architectural choices and the trade-offs behind them.

## ADR-001: Keep Both `/api/v2` and `/api/v3`

Status: Accepted

Context:

- The project needs compatibility with existing PokeAPI-style consumers.
- The project also needs a safer path to evolve contracts and performance behavior.

Decision:

- Keep `/api/v2` as compatibility/parity-oriented routes.
- Evolve `/api/v3` as normalized, include-driven, contract-hardened routes.

Consequences:

- Pros:
  - Existing integration patterns remain supported.
  - New API patterns can evolve without breaking v2 consumers.
  - Performance and contract improvements can be applied progressively in v3.
- Cons:
  - Dual maintenance overhead.
  - Additional test/documentation burden for versioned behavior.

## ADR-002: Rails + PostgreSQL Instead of Static SQLite-Only Delivery

Status: Accepted

Context:

- Upstream PokeAPI data is largely static, but this implementation targets self-hosting, extensibility, and operational controls.

Decision:

- Use Rails 8.1 + PostgreSQL as the primary runtime stack.

Consequences:

- Pros:
  - Rich relational modeling and query optimization options.
  - Extensible app surface (auth, custom endpoints, operational middleware).
  - Better fit for API observability/rate-limiting/caching layers.
- Cons:
  - Higher operational complexity and cost than static-file distribution.
  - Requires active performance and deployment maintenance.

## ADR-003: Include-Driven Expansion for v3 Payloads

Status: Accepted

Context:

- Large default payloads increase response cost and query fanout.
- Consumers need control over payload size and relation expansion.

Decision:

- Keep v3 detail/list payloads compact by default.
- Expand related resources explicitly through `include=...`.
- Support field selection (`fields=...`) and related query controls where available.

Consequences:

- Pros:
  - Lower default response size and query load.
  - Better cacheability and predictable performance budgets.
  - Clearer client intent per request.
- Cons:
  - Slightly higher client complexity.
  - More include-path validation and testing requirements.

## Decision Update Policy

- Record only decisions with repository-wide impact.
- When a decision changes, add a new ADR entry rather than rewriting history.
- Keep each ADR short and tied to measurable outcomes (tests, logs, budgets, or cost).
