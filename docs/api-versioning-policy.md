# API Versioning Policy

This document defines compatibility and deprecation rules for `pokeapi-rails` API versions.

## Scope

- Stable public versions: `/api/v2`, `/api/v3`
- This policy applies to request/response contracts and endpoint availability.

## Version Principles

- URL-based versioning is authoritative (`/api/v2/...`, `/api/v3/...`).
- New breaking behavior must ship in a new major version path.
- Non-breaking additions may ship within an existing major version.

## `/api/v2` Freeze Policy

- `/api/v2` is frozen for compatibility.
- Allowed changes in `/api/v2`:
  - security fixes
  - bug fixes that restore documented behavior
  - operational improvements that do not change response contracts
- Disallowed changes in `/api/v2`:
  - removing fields/endpoints
  - changing field meaning or type
  - changing query semantics in a breaking way

## `/api/v3` Compatibility Policy

- `/api/v3` is opt-in and can evolve.
- Backward-compatible changes allowed:
  - adding optional fields
  - adding optional query params
  - adding new endpoints
- Breaking changes require:
  - RFC update
  - migration notes
  - deprecation window
  - release note/changelog entry

## Deprecation Policy

For any endpoint/query/field deprecation in an active version:

1. Announce deprecation in docs/changelog.
2. Mark deprecation in OpenAPI description.
3. Keep behavior for at least one published deprecation window.
4. Remove only in the next major API version, unless there is a critical security issue.

Default deprecation window target:
- 90 days minimum from public notice.

## Contract Governance

- OpenAPI is the source of truth for each version.
- CI must pass:
  - OpenAPI validation
  - route drift checks for that version
- Any contract change must update tests and OpenAPI in the same PR.

## Release Checklist (Versioned API)

- Update OpenAPI and RFC/progress notes.
- Add/adjust integration tests.
- Pass contract drift/validation checks.
- Publish migration guidance for client-facing behavior changes.
