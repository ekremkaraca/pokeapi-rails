# /api/v2 -> /api/v3 Migration Guide

This guide covers currently implemented `/api/v3` resources:

- `pokemon`
- `ability`
- `type`
- `move`
- `item`
- `generation`
- `version-group`
- `region`
- `version`
- `pokemon-species`
- `evolution-chain`
- `evolution-trigger`
- `growth-rate`
- `nature`
- `gender`
- `egg-group`
- `encounter-method`
- `encounter-condition`
- `encounter-condition-value`
- `berry`
- `berry-firmness`
- `berry-flavor`
- `contest-type`
- `contest-effect`
- `item-category`
- `item-pocket`
- `item-attribute`
- `item-fling-effect`
- `language`
- `location`
- `location-area`
- `machine`
- `move-ailment`
- `move-battle-style`
- `move-category`
- `move-damage-class`
- `move-learn-method`
- `move-target`
- `characteristic`
- `stat`
- `super-contest-effect`
- `pal-park-area`
- `pokeathlon-stat`
- `pokedex`
- `pokemon-color`
- `pokemon-form`
- `pokemon-habitat`
- `pokemon-shape`

## Endpoint Mapping

- `/api/v2/pokemon` -> `/api/v3/pokemon`
- `/api/v2/pokemon/{id}` -> `/api/v3/pokemon/{id}`
- `/api/v2/ability` -> `/api/v3/ability`
- `/api/v2/ability/{id}` -> `/api/v3/ability/{id}`
- `/api/v2/type` -> `/api/v3/type`
- `/api/v2/type/{id}` -> `/api/v3/type/{id}`
- `/api/v2/move` -> `/api/v3/move`
- `/api/v2/move/{id}` -> `/api/v3/move/{id}`
- `/api/v2/item` -> `/api/v3/item`
- `/api/v2/item/{id}` -> `/api/v3/item/{id}`
- `/api/v2/generation` -> `/api/v3/generation`
- `/api/v2/generation/{id}` -> `/api/v3/generation/{id}`
- `/api/v2/version-group` -> `/api/v3/version-group`
- `/api/v2/version-group/{id}` -> `/api/v3/version-group/{id}`
- `/api/v2/region` -> `/api/v3/region`
- `/api/v2/region/{id}` -> `/api/v3/region/{id}`
- `/api/v2/version` -> `/api/v3/version`
- `/api/v2/version/{id}` -> `/api/v3/version/{id}`
- `/api/v2/pokemon-species` -> `/api/v3/pokemon-species`
- `/api/v2/pokemon-species/{id}` -> `/api/v3/pokemon-species/{id}`
- `/api/v2/evolution-chain` -> `/api/v3/evolution-chain`
- `/api/v2/evolution-chain/{id}` -> `/api/v3/evolution-chain/{id}`
- `/api/v2/evolution-trigger` -> `/api/v3/evolution-trigger`
- `/api/v2/evolution-trigger/{id}` -> `/api/v3/evolution-trigger/{id}`
- `/api/v2/growth-rate` -> `/api/v3/growth-rate`
- `/api/v2/growth-rate/{id}` -> `/api/v3/growth-rate/{id}`
- `/api/v2/nature` -> `/api/v3/nature`
- `/api/v2/nature/{id}` -> `/api/v3/nature/{id}`
- `/api/v2/gender` -> `/api/v3/gender`
- `/api/v2/gender/{id}` -> `/api/v3/gender/{id}`
- `/api/v2/egg-group` -> `/api/v3/egg-group`
- `/api/v2/egg-group/{id}` -> `/api/v3/egg-group/{id}`
- `/api/v2/encounter-method` -> `/api/v3/encounter-method`
- `/api/v2/encounter-method/{id}` -> `/api/v3/encounter-method/{id}`
- `/api/v2/encounter-condition` -> `/api/v3/encounter-condition`
- `/api/v2/encounter-condition/{id}` -> `/api/v3/encounter-condition/{id}`
- `/api/v2/encounter-condition-value` -> `/api/v3/encounter-condition-value`
- `/api/v2/encounter-condition-value/{id}` -> `/api/v3/encounter-condition-value/{id}`
- `/api/v2/berry` -> `/api/v3/berry`
- `/api/v2/berry/{id}` -> `/api/v3/berry/{id}`
- `/api/v2/berry-firmness` -> `/api/v3/berry-firmness`
- `/api/v2/berry-firmness/{id}` -> `/api/v3/berry-firmness/{id}`
- `/api/v2/berry-flavor` -> `/api/v3/berry-flavor`
- `/api/v2/berry-flavor/{id}` -> `/api/v3/berry-flavor/{id}`
- `/api/v2/contest-type` -> `/api/v3/contest-type`
- `/api/v2/contest-type/{id}` -> `/api/v3/contest-type/{id}`
- `/api/v2/contest-effect` -> `/api/v3/contest-effect`
- `/api/v2/contest-effect/{id}` -> `/api/v3/contest-effect/{id}`
- `/api/v2/item-category` -> `/api/v3/item-category`
- `/api/v2/item-category/{id}` -> `/api/v3/item-category/{id}`
- `/api/v2/item-pocket` -> `/api/v3/item-pocket`
- `/api/v2/item-pocket/{id}` -> `/api/v3/item-pocket/{id}`
- `/api/v2/item-attribute` -> `/api/v3/item-attribute`
- `/api/v2/item-attribute/{id}` -> `/api/v3/item-attribute/{id}`
- `/api/v2/item-fling-effect` -> `/api/v3/item-fling-effect`
- `/api/v2/item-fling-effect/{id}` -> `/api/v3/item-fling-effect/{id}`
- `/api/v2/language` -> `/api/v3/language`
- `/api/v2/language/{id}` -> `/api/v3/language/{id}`
- `/api/v2/location` -> `/api/v3/location`
- `/api/v2/location/{id}` -> `/api/v3/location/{id}`
- `/api/v2/location-area` -> `/api/v3/location-area`
- `/api/v2/location-area/{id}` -> `/api/v3/location-area/{id}`
- `/api/v2/machine` -> `/api/v3/machine`
- `/api/v2/machine/{id}` -> `/api/v3/machine/{id}`
- `/api/v2/move-ailment` -> `/api/v3/move-ailment`
- `/api/v2/move-ailment/{id}` -> `/api/v3/move-ailment/{id}`
- `/api/v2/move-battle-style` -> `/api/v3/move-battle-style`
- `/api/v2/move-battle-style/{id}` -> `/api/v3/move-battle-style/{id}`
- `/api/v2/move-category` -> `/api/v3/move-category`
- `/api/v2/move-category/{id}` -> `/api/v3/move-category/{id}`
- `/api/v2/move-damage-class` -> `/api/v3/move-damage-class`
- `/api/v2/move-damage-class/{id}` -> `/api/v3/move-damage-class/{id}`
- `/api/v2/move-learn-method` -> `/api/v3/move-learn-method`
- `/api/v2/move-learn-method/{id}` -> `/api/v3/move-learn-method/{id}`
- `/api/v2/move-target` -> `/api/v3/move-target`
- `/api/v2/move-target/{id}` -> `/api/v3/move-target/{id}`
- `/api/v2/characteristic` -> `/api/v3/characteristic`
- `/api/v2/characteristic/{id}` -> `/api/v3/characteristic/{id}`
- `/api/v2/stat` -> `/api/v3/stat`
- `/api/v2/stat/{id}` -> `/api/v3/stat/{id}`
- `/api/v2/super-contest-effect` -> `/api/v3/super-contest-effect`
- `/api/v2/super-contest-effect/{id}` -> `/api/v3/super-contest-effect/{id}`
- `/api/v2/pal-park-area` -> `/api/v3/pal-park-area`
- `/api/v2/pal-park-area/{id}` -> `/api/v3/pal-park-area/{id}`
- `/api/v2/pokeathlon-stat` -> `/api/v3/pokeathlon-stat`
- `/api/v2/pokeathlon-stat/{id}` -> `/api/v3/pokeathlon-stat/{id}`
- `/api/v2/pokedex` -> `/api/v3/pokedex`
- `/api/v2/pokedex/{id}` -> `/api/v3/pokedex/{id}`
- `/api/v2/pokemon-color` -> `/api/v3/pokemon-color`
- `/api/v2/pokemon-color/{id}` -> `/api/v3/pokemon-color/{id}`
- `/api/v2/pokemon-form` -> `/api/v3/pokemon-form`
- `/api/v2/pokemon-form/{id}` -> `/api/v3/pokemon-form/{id}`
- `/api/v2/pokemon-habitat` -> `/api/v3/pokemon-habitat`
- `/api/v2/pokemon-habitat/{id}` -> `/api/v3/pokemon-habitat/{id}`
- `/api/v2/pokemon-shape` -> `/api/v3/pokemon-shape`
- `/api/v2/pokemon-shape/{id}` -> `/api/v3/pokemon-shape/{id}`

## Response Shape Differences

- `/api/v3` list responses use a consistent envelope:
  - `count`, `next`, `previous`, `results`
- `/api/v3` detail responses are intentionally compact by default.
- `/api/v3` not-found and query errors use a standardized envelope:
  - `error.code`, `error.message`, `error.details`, `error.request_id`

## Query Convention Differences

Current `/api/v3` query controls:

- Pagination: `limit`, `offset`
- Name filter (legacy): `q`
- Field filter: `filter[name]=...`
- Sorting: `sort=field,-field`
- Sparse fields: `fields=...`
- Include expansion: `include=...`

Notes:

- Prefer `filter[name]` for forward-compatible filtering.
- If both `q` and `filter[name]` are provided, both are applied (AND semantics).

### Resource Include Support

- `pokemon`: `include=abilities`
- `ability`: `include=pokemon`
- `type`: `include=pokemon`
- `move`: `include=pokemon`
- `item`: `include=category`
- `generation`: `include=main_region`
- `version-group`: `include=generation`
- `region`: `include=generations`
- `version`: `include=version_group`
- `pokemon-species`: `include=generation`
- `evolution-chain`: `include=pokemon_species`
- `evolution-trigger`: no include expansions in current draft
- `growth-rate`: no include expansions in current draft
- `nature`: no include expansions in current draft
- `gender`: no include expansions in current draft
- `egg-group`: no include expansions in current draft
- `encounter-method`: no include expansions in current draft
- `encounter-condition`: no include expansions in current draft
- `encounter-condition-value`: no include expansions in current draft
- `berry`: no include expansions in current draft
- `machine`: `include=item`
- `move-ailment`: no include expansions in current draft
- `move-battle-style`: no include expansions in current draft
- `move-category`: no include expansions in current draft
- `move-damage-class`: no include expansions in current draft
- `move-learn-method`: no include expansions in current draft
- `move-target`: no include expansions in current draft
- `characteristic`: no include expansions in current draft
- `stat`: no include expansions in current draft
- `super-contest-effect`: no include expansions in current draft
- `pal-park-area`: no include expansions in current draft
- `pokeathlon-stat`: no include expansions in current draft
- `pokedex`: no include expansions in current draft
- `pokemon-color`: no include expansions in current draft
- `pokemon-form`: no include expansions in current draft
- `pokemon-habitat`: no include expansions in current draft
- `pokemon-shape`: no include expansions in current draft

## Example Migrations

### 1) Basic list

- v2: `GET /api/v2/pokemon?limit=20&offset=0`
- v3: `GET /api/v3/pokemon?limit=20&offset=0`

### 2) Sparse fields

- v3 only:
  - `GET /api/v3/ability?fields=id,name,url`

### 3) Include related data

- v3 only:
  - `GET /api/v3/pokemon/1?include=abilities`
  - `GET /api/v3/ability/65?include=pokemon`

### 4) Sort list output

- v3 only:
  - `GET /api/v3/type?sort=-name`

### 5) Structured field filter

- v3 only:
  - `GET /api/v3/pokemon?filter[name]=bulbasaur`

## Caching Behavior

`/api/v3` supports conditional GET:

- Response includes `ETag`.
- Clients can send `If-None-Match`.
- Server returns `304 Not Modified` when representation is unchanged.

`ETag` varies by query representation (including `fields`, `include`, `sort`, and pagination/filter params for list endpoints).

## Rollout Recommendation

1. Move one client workflow to `/api/v3` endpoints first.
2. Start with compact responses, then add `fields`/`include` intentionally.
3. Enable conditional GET in clients to reduce transfer/latency.
4. Keep `/api/v2` fallback during migration window.
