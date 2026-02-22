# AGENTS.md
(Ruby on Rails 8.1 AI-Assisted Development Workflow)

This repository uses AI coding assistants (e.g., Codex) as implementation accelerators — not architectural authorities.

Humans own:
- Architecture decisions
- Security
- Data integrity
- Production safety
- Final review

---

# 1. Goals

- Keep Rails code idiomatic, simple, and readable
- Prefer small diffs and test-first development
- Maintain consistent service object architecture
- Enforce clean JSON API contracts
- Use AI to accelerate implementation, not replace judgment

---

# 2. Environment

- Rails 8.1
- Ruby 4.0
- PostgreSQL
- Minitest (default Rails test framework)
- API-first backend (JSON responses)

AI must generate code compatible with Rails 8.1 conventions and Ruby 4.0 syntax.

---

# 3. Model Usage Strategy

## Codex Usage Policy

Use Codex for:

- Feature implementation
- Multi-file refactors
- Architectural improvements
- Query optimization & performance debugging
- Concurrency / background jobs
- Security-sensitive logic (auth, payments)
- Legacy code reasoning
- Regression analysis
- Test generation
- Documentation drafting

If AI output is inconsistent, unclear, or overly complex:
- Refine the prompt.
- Reduce scope.
- Request step-by-step reasoning.
- Break task into smaller parts.

---

# 4. Rails Architecture Conventions (AI Must Follow)

## Controller Rules

- Controllers must remain thin.
- No business logic inside controllers.
- Use strong parameters.
- Always return structured JSON.
- Use proper HTTP status codes.

---

## JSON Response Contract

All API responses must follow:

{
  "success": boolean,
  "data": {},
  "errors": []
}

Rules:
- Do not leak exception messages.
- Validation errors must be structured.
- 422 for validation errors.
- 401/403 for authorization failures.
- 404 for missing records.

Compatibility exception:
- Endpoints that must preserve upstream PokeAPI parity (especially `/api/v2`, and `/api/v3` where explicitly required) may keep canonical upstream payload shapes instead of `{ success, data, errors }`.
- When using a parity exception, tests must assert the exact expected payload contract for that endpoint.

---

## Service Object Pattern

Primary business orchestration must live in:

app/services/

Structure:

- initialize with keyword arguments
- single public `call` method
- return a Result object:
  - success?
  - data
  - errors
- wrap multi-table writes in transactions
- do not rescue broadly unless required

Models may contain lightweight domain logic (scopes, predicates, small helpers), but not cross-aggregate orchestration.
No controller logic leaks.

## Performance Guardrails

- Eliminate N+1 queries on API paths.
- Keep query count stable for high-traffic list/detail endpoints as related row counts grow.
- Respect include-expansion caps and response budget checks where defined.
- For optimized paths, document expected p95 and query-count budget in tests/docs when available.

---

## Minitest Testing Rules

- Every feature must include tests.
- API endpoints → integration tests (ActionDispatch::IntegrationTest)
- Services → unit tests (ActiveSupport::TestCase)
- Edge cases must be covered.
- Avoid excessive mocking.
- Use fixtures or factories consistently (if applicable).
- Tests must run via: `bin/rails test`

No feature without tests.

Refactor mode exception:
- For behavior-preserving refactors, use characterization tests first, then refactor, then re-run the relevant suite.

---

# 5. Standard AI Workflows

---

## A. Feature Development (Test-First Workflow)

### Step 1 — Generate Tests Only

Prompt AI to:
- Write failing Minitest integration tests
- Write service unit tests
- Define JSON contract
- List required files

Do NOT implement yet.

---

### Step 2 — Minimal Implementation

Prompt AI to:
- Implement minimal code to satisfy tests
- Include migration
- Add validations
- Add service object
- Use transactions if needed

---

### Step 3 — Hardening

Prompt AI to:
- Add edge case tests
- Add authorization checks
- Eliminate N+1 queries
- Suggest indexes

---

### Done Criteria

- All tests pass (`bin/rails test`)
- No N+1 queries
- JSON contract consistent
- Migrations safe
- Code reviewed by human

---

## B. Refactor Workflow

Rules:

- Behavior must remain identical
- Add characterization tests first
- Extract service objects
- Reduce controller complexity
- Remove N+1 queries

AI must provide:
- Refactored code
- Explanation of changes
- Tests added or updated

---

## C. Query Optimization Workflow

AI must:

- Explain current query problem
- Provide optimized ActiveRecord version
- Suggest DB indexes (migration format)
- Explain expected improvement
- Suggest measurement approach

---

## D. Zero-Downtime Migration Workflow

AI must:

- Avoid long locks
- Use concurrent indexes where possible
- Avoid rewriting large tables
- Provide rollback strategy
- Explain safety considerations
- Use `disable_ddl_transaction!` for concurrent index operations.
- Split schema changes and backfills when needed.
- Backfill in batches for large tables.
- Prefer additive changes first, then cleanup in a later deploy.

---

# 6. Prompt Templates

---

## Feature Implementation Template

You are a senior Ruby on Rails 8.1 engineer.

Context:
- Rails 8.1
- Ruby 4.0
- PostgreSQL
- Minitest
- Service object architecture

Task:
Implement [FEATURE DESCRIPTION].

Constraints:
- Thin controller
- Business logic in service
- Strong params
- Validations
- Proper HTTP status codes
- JSON contract:
  { success, data, errors }

Deliver:
1. Migration
2. Model
3. Service object
4. Controller
5. Routes
6. Minitest tests (integration + unit)
7. Example curl request

---

## Refactor Template

Act as a senior Rails architect.

Refactor this code to:
- Extract service objects
- Improve testability
- Reduce controller complexity
- Remove N+1 queries

Keep behavior identical.

Provide:
1. Refactored code
2. Explanation
3. Updated Minitest tests

Code:
[PASTE]

---

## ActiveRecord Optimization Template

You are a Rails performance specialist.

Optimize this query:
- Eliminate N+1
- Improve SQL efficiency
- Suggest indexes (migration format)

Provide:
1. Optimized Rails code
2. Migration for indexes
3. Explanation

Code:
[PASTE]

---

## Zero-Downtime Migration Template

Generate a Rails migration for:
[CHANGE]

Constraints:
- Production-safe
- Concurrent indexes
- No long locks
- Includes rollback

---

## Rails → TypeScript Contract Template

Given this Rails JSON response:
[JSON SAMPLE]

Generate:
1. TypeScript interface
2. Zod schema
3. Example fetch usage

---

# 7. AI Output Review Checklist

Before merging AI-generated code, verify:

[ ] Tests exist and are meaningful  
[ ] Strong parameters used  
[ ] Authorization present (if required)  
[ ] No N+1 queries  
[ ] Performance gates/budgets respected (where defined)  
[ ] DB constraints align with validations  
[ ] Migration safe for production  
[ ] JSON contract correct (or parity exception explicitly documented/tested)  
[ ] No secrets in logs  
[ ] Code is idiomatic Rails 8.1  
[ ] Ruby 4.0 compatible syntax used  

---

# 8. Definition of Done

A task is complete only if:

- Tests pass locally and in CI
- Code follows repo conventions
- JSON contract is consistent
- Migration is safe
- Human reviewer approves

---

# 9. AI Philosophy

Prefer:
- Simple over clever
- Explicit over magical
- Small PRs over large refactors
- Test-first over implementation-first

AI assists.
Humans decide.
