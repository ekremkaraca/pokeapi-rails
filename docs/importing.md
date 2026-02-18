# Importing Data

Imports read CSV files and load them into Rails tables.
Runtime API responses should read from DB models, with CSV used only for import/seeding.

Import tasks are generated from a single task registry in `lib/tasks/pokeapi_import.rake`, so new importers can be added without repeating rake boilerplate.
CSV parsing is handled with Ruby's `CSV` parser.

## Source Path

Default source path:

`db` (relative to this project root), resolving to `db/data/v2/csv/*.csv`

This means imports work out-of-the-box when CSVs are committed/copied into this repository.

Override source path:

```bash
POKEAPI_SOURCE_DIR=~/Desktop/Tries/pokeapi bin/rails pokeapi:import:pokemon
```

## Available Import Tasks

Use these commands to inspect the current registry:

```bash
bin/rails -T pokeapi:import
bin/rails pokeapi:import:all
```

Recently added relation tasks used by DB-backed endpoint payloads include:

```bash
bin/rails pokeapi:import:encounter_slot
bin/rails pokeapi:import:encounter
bin/rails pokeapi:import:encounter_condition_value_map
```

## Typical Flow

```bash
bin/rails db:migrate
bin/rails pokeapi:import:all

# or import resources individually
bin/rails pokeapi:import:pokemon
bin/rails pokeapi:import:ability
bin/rails pokeapi:import:move
bin/rails pokeapi:import:pokemon_move
```

## Skip Unchanged CSVs

For repeated local imports, you can skip resources whose source CSV has not changed:

```bash
POKEAPI_SKIP_UNCHANGED=1 bin/rails pokeapi:import:all
```

Optional checksum store path (default: `tmp/pokeapi_import_checksums.json`):

```bash
POKEAPI_SKIP_UNCHANGED=1 POKEAPI_IMPORT_CHECKSUM_FILE=tmp/pokeapi_import_checksums.json bin/rails pokeapi:import:all
```

When enabled, each importer compares the current CSV SHA-256 to the last successful import checksum and skips unchanged resources.
