# Next Targets

This file tracks active and upcoming work only.

Historical completions moved to: `docs/planning/completed-targets.md`.

## Active Focus (This Week)

1. Measure-first optimization for `/api/v2/move/:id`
   - Goal:
     - reduce p95 latency and query cost on the heaviest v2 show path.
   - Metric:
     - `duration_ms`, `db_ms`, and query count before/after on the same endpoint cases.
   - Change:
     - optimize eager loading / payload assembly without changing v2 response contract.
   - Validation:
     - focused integration tests + query-budget assertions + before/after note in `docs/planning/recent-changes.md`.

2. Keep CI deterministic and fast
   - Goal:
     - keep main branch CI green with low noise.
   - Metric:
     - zero flaky failures across smoke/integration/model-service/lint jobs.
   - Change:
     - continue removing duplication and hardening workflow steps.
   - Validation:
     - successful CI runs on merge commits and workflow command parity with local runs.

3. Maintain docs clarity for version behavior
   - Goal:
     - make v2 vs v3 behavior obvious to contributors/users.
   - Metric:
     - docs and homepage examples reflect current include/default payload behavior.
   - Change:
     - keep docs synchronized when endpoint behavior or contracts change.
   - Validation:
     - docs review passes with no stale links and no contradictory version guidance.

## Execution Discipline Improvements (Active)

1. Scope freeze per cycle
   - Run in weekly batches with fixed scope:
     - one reliability task
     - one performance task
     - one docs/communication task
   - Avoid unbounded "continue" chains during a batch.

2. Measurement-first optimization
   - For every performance change, record:
     - baseline (`duration_ms`, `db_ms`, query count)
     - post-change metrics
     - endpoint + environment used for comparison
   - No optimization PR is complete without before/after evidence.

3. Task template required for all new work
   - Each task entry must include:
     - Goal
     - Metric
     - Change
     - Validation
   - Keep entries short and concrete.

4. Prioritize bottlenecks over visible polish
   - Use production logs and query budgets to pick work.
   - UI/content polish is only scheduled after top latency/reliability items are green.

5. Decision transparency by default
   - Major choices must be captured in:
     - `docs/architecture/architecture-decisions.md`
   - If a decision changes, add a new ADR entry rather than silently replacing rationale.

6. External feedback triage policy
   - Convert technically valid criticism into tracked tasks.
   - Ignore non-actionable/personal attacks and do not extend thread debates.

### Completion Criteria for This Section

- [ ] At least two weekly batches completed using fixed-scope planning.
- [ ] Every performance PR merged with explicit before/after metrics.
- [ ] New tasks in this file follow Goal/Metric/Change/Validation format.
- [ ] At least one new ADR added when a repository-wide decision changes.
