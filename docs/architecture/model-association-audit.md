# Model Association Audit

This document summarizes the recent association-normalization pass across the Rails models.

## Goals

- Ensure FK-backed tables have explicit `belongs_to` / `has_many` (or `has_one`) mappings.
- Add explicit `foreign_key` and `inverse_of` for non-standard table/model naming.
- Keep association behavior safe for lookup/reference tables via `dependent` strategies.
- Refactor controllers to use associations where this improves readability without changing response shape.

## Scope Covered

- Ability + ability prose/name/flavor/changelog graph
- Pokemon + species + encounter graph
- Move + move metadata/changelog/combo graph
- Item graph
- Language graph
- Berry + contest graph
- Region/location/generation/pokedex/version-group graph
- Type/stat/nature/characteristic/pal-park graph

## Key Outcomes

- FK-backed model coverage was normalized:
  - no remaining models with `*_id` schema columns lacking corresponding `belongs_to`.
- Parent-side inverse links were added where missing to support:
  - bidirectional traversal
  - predictable eager loading
  - fewer ad-hoc lookup maps in controllers
- Several v2 controllers now use model associations directly (while preserving payloads):
  - `ability`
  - `generation`
  - `type`
  - `move`
  - `version-group`
  - plus earlier updates in `item`, `pokemon-species`, and related resources

## Standalone Lookup Models

These models intentionally remain standalone (no associations) because schema has no FK links to/from them:

- `PokePokeathlonStat`
- `PokeMoveBattleStyle`
- `PokeGender`
- `PokeEvolutionTrigger`

If future schema adds join/reference tables (for example `..._id` columns pointing to these tables), associations should be added then.

## Verification

The association pass was validated with:

- targeted RuboCop runs on touched model/controller files
- focused integration tests on affected domains (`v2` + `v3`)
- repeated checks that no FK-backed model remains association-missing

Example local checks:

```bash
# Detect FK-backed models that still have no associations
for f in app/models/*.rb; do
  ids=$(rg -n "#\s+\w+_id\s+:" "$f" | wc -l | tr -d ' ')
  assoc=$(rg -n "belongs_to|has_many|has_one|has_and_belongs_to_many" "$f" | wc -l | tr -d ' ')
  if [ "$ids" -gt 0 ] && [ "$assoc" -eq 0 ]; then
    echo "$f"
  fi
done | sort
```

```bash
# Detect FK-backed models lacking belongs_to
for f in app/models/*.rb; do
  if rg -q "#\s+\w+_id\s+:" "$f"; then
    if ! rg -q "belongs_to" "$f"; then
      echo "$f"
    fi
  fi
done | sort
```

