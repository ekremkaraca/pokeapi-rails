# Solo Maintainer Roadmap

This roadmap is optimized for one maintainer shipping incrementally with limited time.

## Scope

- Keep the app reliable for personal and small public usage.
- Prioritize API correctness, performance, and operational safety over feature volume.
- Avoid platform complexity unless it materially improves stability or cost.

## Working Rules

- Ship in small, test-backed PRs.
- Keep `/api/v2` parity stable while continuing `/api/v3` improvements.
- Use production logs and query budgets to choose work, not guesswork.
- Document every meaningful change in `docs/planning/recent-changes.md`.
- Follow active execution-discipline rules in `docs/planning/next-targets.md` (`Execution Discipline Improvements`).

## Milestone 1: Reliability Baseline (1-2 weeks)

Goal: reduce breakage risk and keep deployments predictable.

Deliverables:

- CI gate covers smoke + core integration suites.
- `db:prepare` and seed/import tasks are documented and reproducible.
- Request logging is consistent (`duration_ms`, `db_ms`, `view_ms` sanity).
- 404/invalid-path handling remains lightweight.

Done when:

- CI passes on every main branch commit.
- No recurring boot/deploy regressions for one week.
- Known operational tasks are documented in `docs/operations/deployment.md`.

## Milestone 2: v2 Performance Hardening (2-3 weeks)

Goal: improve the slowest `/api/v2` endpoints with stable query behavior.

Deliverables:

- Profile and optimize high-cost `show` actions (`pokemon`, `move`, `pokemon-species` first).
- Remove remaining N+1 patterns on v2 show paths.
- Add/adjust DB indexes for proven query hotspots.
- Add regression tests for query-count budgets on top endpoints.

Done when:

- p95 for tested hot `show` endpoints consistently improves from current baseline.
- Query counts stay within test budgets across representative fixture sizes.
- No payload-contract regressions in v2 integration tests.

## Milestone 3: Edge + Cost Optimization (1-2 weeks)

Goal: reduce unnecessary traffic cost and improve abuse resistance.

Deliverables:

- Rack::Attack limits validated against real traffic patterns.
- Rate-limit and cache headers are consistent on API responses.
- CDN cache rules aligned with route behavior (cacheable list/show where safe).
- Home/non-API traffic remains cheap (small responses, crawler-resistant defaults).

Done when:

- Egress trend is flat or reduced under similar traffic.
- Abuse bursts are throttled without harming normal usage.
- Logs show clean request metadata for incident diagnosis.

## Milestone 4: Product Clarity (ongoing)

Goal: make usage differences between v2 and v3 obvious and intentional.

Deliverables:

- Keep homepage/API docs clear about:
  - v2 default embedded payload behavior
  - v3 include-driven expansion model
- Publish a short migration guide for common v2 -> v3 reads.
- Keep endpoint examples current for both versions.

Done when:

- New users can call v2/v3 correctly without source code reading.
- Repeated support questions decrease for include behavior and path usage.

## Weekly Cadence (Practical)

1. Monday: review logs, pick one bottleneck + one reliability task.
2. Midweek: ship one performance fix with tests.
3. End of week: update docs/changelog and re-check CI + deploy path.

## Backlog Parking Lot

Only pull these in after milestones above are stable:

- API docs generation reintroduction (postponed `oas_rails` path).
- Optional GraphQL endpoint exploration.
- Non-critical UI polish on homepage.
- Additional deployment platform experiments.

## Success Criteria (Quarterly)

- Stable deploys with no emergency rollbacks.
- Core API tests always green in CI.
- Noticeable latency gap maintained: v3 significantly faster than v2 on heavy endpoints.
- Operating cost stays within acceptable personal budget.
