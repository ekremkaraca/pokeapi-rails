# Implementation Status

This document tracks what has already been implemented in `pokeapi-rails` during the Django -> Rails adoption.

## Completed Foundations

- API root endpoint implemented:
  - `GET /api/v2` and `GET /api/v2/`
  - Lists currently available endpoints (similar to Django/DRF API root behavior).
- App root redirect implemented:
  - `GET /` -> `301 /api/v2/`
- Shared API behavior implemented and reused across resources:
  - ID-or-name retrieval
  - `q` filter on `name`
  - limit/offset pagination with `count`, `next`, `previous`, `results`
  - 404 handling for invalid lookups
  - canonical URL output with exactly one trailing slash
- CSV import pattern implemented:
  - one importer class per resource, backed by a shared generic importer base
  - rebuild strategy (`delete_all` + `insert_all!`)
  - source IDs preserved
  - chunked parsing via Ruby `CSV`
  - default in-repo source path (`db/data/v2/csv`) with `POKEAPI_SOURCE_DIR` override support
  - CSV files are ingestion-only; API responses are built from database tables at runtime
- Import rake tasks standardized:
  - generated from a single registry in `lib/tasks/pokeapi_import.rake`
  - consistent command pattern and output across all import tasks
  - dependency-aware `pokeapi:import:all` task for one-command full imports
- API controller pattern standardized:
  - shared concern for name-searchable resources (`id` or `name` + `q` filter)
  - shared concern for ID-only resources
  - per-resource controllers keep only resource-specific detail fields and routing helpers
- Parity tooling implemented:
  - `pokeapi:parity:diff` task compares sampled Django vs Rails responses
  - normalized base-URL handling to avoid false positives on host differences
  - profile-based path sets (`smoke`, `core`, `full`)
  - grouped failure output by endpoint/path
  - clearer status mismatch diagnostics (including connectivity issues)
  - redirect/trailing-slash normalization improvements for stable comparisons

## Implemented API Endpoints

Each endpoint includes list + detail routes under `/api/v2`.

- `ability`
- `berry`
- `berry-firmness`
- `berry-flavor`
- `characteristic`
- `contest-effect`
- `contest-type`
- `evolution-chain`
- `evolution-trigger`
- `encounter-condition`
- `encounter-condition-value`
- `egg-group`
- `encounter-method`
- `generation`
- `gender`
- `growth-rate`
- `item`
- `item-attribute`
- `item-category`
- `item-fling-effect`
- `item-pocket`
- `language`
- `location`
- `location-area`
- `machine`
- `move`
- `move-ailment`
- `move-battle-style`
- `move-category`
- `move-damage-class`
- `move-learn-method`
- `move-target`
- `nature`
- `pal-park-area`
- `pokedex`
- `pokemon`
- `pokemon/{id}/encounters`
- `pokemon-color`
- `pokemon-form`
- `pokemon-habitat`
- `pokemon-shape`
- `pokemon-species`
- `pokeathlon-stat`
- `region`
- `stat`
- `super-contest-effect`
- `type`
- `version`
- `version-group`

## Implemented Import Tasks

All tasks are exposed as `bin/rails pokeapi:import:<name>`.

- `ability`
- `berry`
- `berry_firmness`
- `berry_flavor`
- `characteristic`
- `contest_effect`
- `contest_type`
- `evolution_chain`
- `evolution_trigger`
- `encounter_condition`
- `encounter_condition_value`
- `encounter_method`
- `egg_group`
- `generation`
- `gender`
- `growth_rate`
- `item`
- `item_attribute`
- `item_category`
- `item_fling_effect`
- `item_pocket`
- `language`
- `location`
- `location_area`
- `machine`
- `move`
- `move_ailment`
- `move_battle_style`
- `move_category`
- `move_damage_class`
- `move_learn_method`
- `move_target`
- `nature`
- `pal_park_area`
- `pokedex`
- `pokemon`
- `pokemon_color`
- `pokemon_form`
- `pokemon_habitat`
- `pokemon_shape`
- `pokemon_species`
- `pokeathlon_stat`
- `region`
- `stat`
- `super_contest_effect`
- `type`
- `version`
- `version_group`

Additional relation/prose/changelog import tasks are also registered in
`lib/tasks/pokeapi_import.rake` (for richer detail payloads), including:

- `encounter`
- `encounter_slot`
- `encounter_condition_value_map`
- `pokemon_move`
- `pokemon_ability`
- `pokemon_stat`
- `pokemon_type`
- `pokemon_species_flavor_text`
- `move_meta`
- `move_flavor_text`
- `move_changelog`
- `move_effect_prose`

## Test Coverage Added

- Integration tests for each implemented `/api/v2/*` endpoint:
  - list behavior
  - filter behavior (`q`)
  - show by ID and by name
  - trailing slash handling
  - invalid token handling (`404`)
- Importer tests for each implemented importer:
  - rebuild semantics
  - key null/blank edge-cases
  - ID preservation (including negative IDs for `move-ailment`)
- Root endpoint test verifying endpoint discovery payload.

## Recent Parity Milestone

- Core parity profile is now green:
  - `PATH_PROFILE=core`
  - `Compared 20 path(s): 20 passed, 0 failed`
- This includes list/detail checks for major resources and nested response parity for:
  - `ability`
  - `generation`
  - `item`
  - `location`
  - `move`
  - `pokemon`
  - `pokemon-species`
  - `type`
  - `version-group`

## Recently Completed Detail Work

The following richer detail payloads were implemented to match source response contracts:

- `GET /api/v2/ability/:id/`
  - effect entries/effect changes/flavor text/name translations/pokemon links
- `GET /api/v2/generation/:id/`
  - related abilities/moves/species/types/version groups/main region
- `GET /api/v2/item/:id/`
  - attributes/effects/flavor text/game indices/held-by/machines/sprites
- `GET /api/v2/location/:id/`
  - areas/game indices/names/region
- `GET /api/v2/move/:id/`
  - contest combos/effects/flavor text/meta/stat changes/machines/past values
- `GET /api/v2/pokemon/:id/`
  - full source-shaped detail payload (abilities, moves, stats, types, sprites, cries, species, etc.)
- `GET /api/v2/pokemon/:id/encounters`
  - grouped location/version encounter output with method/condition details
- `GET /api/v2/pokemon-species/:id/`
  - flavor text/genera/names/egg groups/varieties/pokedex data/pal park data
- `GET /api/v2/type/:id/`
  - damage relations/past damage relations/game indices/moves/pokemon/sprites
- `GET /api/v2/version-group/:id/`
  - generation/move learn methods/pokedexes/regions/versions

These detail payloads now resolve from DB-backed relation tables (not runtime CSV reads).

## Recent Performance Checkpoint

- `GET /api/v2/pokemon/1/encounters` now completes around `119ms` with `30 queries`
  (ActiveRecord time ~`46.8ms`), after migrating encounter payload building to DB lookups and batched record loading.

## CSV Parsing Reliability Improvements

- Added tolerant parsing fallback for malformed multiline CSV rows.
- Added targeted early-stop parsing for large flavor-text sources.
- Preserved control characters (like form feed `\f`) where required for strict parity.

## Notes

- Some source resources use singular table names. Rails models are explicitly mapped (`self.table_name = ...`) where needed.
- `move-ailment` uses signed IDs from source data (includes `-1` and `0`), so its table uses explicit integer primary key setup.
- `move-ailment` has custom importer sequence reset logic to safely support signed IDs.
