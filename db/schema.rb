# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_17_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ability", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "generation_id"
    t.boolean "is_main_series", default: true, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_ability_on_generation_id"
    t.index [ "is_main_series" ], name: "index_ability_on_is_main_series"
    t.index [ "name" ], name: "index_ability_on_name", unique: true
  end

  create_table "ability_changelog", force: :cascade do |t|
    t.integer "ability_id", null: false
    t.integer "changed_in_version_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "ability_id" ], name: "index_ability_changelog_on_ability_id"
    t.index [ "changed_in_version_group_id" ], name: "index_ability_changelog_on_changed_in_version_group_id"
  end

  create_table "ability_changelog_prose", force: :cascade do |t|
    t.integer "ability_changelog_id", null: false
    t.datetime "created_at", null: false
    t.text "effect"
    t.integer "local_language_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "ability_changelog_id", "local_language_id" ], name: "idx_ability_changelog_prose_unique", unique: true
    t.index [ "local_language_id" ], name: "index_ability_changelog_prose_on_local_language_id"
  end

  create_table "ability_flavor_text", force: :cascade do |t|
    t.integer "ability_id", null: false
    t.datetime "created_at", null: false
    t.text "flavor_text"
    t.integer "language_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "ability_id", "version_group_id", "language_id" ], name: "idx_ability_flavor_text_lookup"
    t.index [ "ability_id" ], name: "index_ability_flavor_text_on_ability_id"
    t.index [ "language_id" ], name: "index_ability_flavor_text_on_language_id"
    t.index [ "version_group_id" ], name: "index_ability_flavor_text_on_version_group_id"
  end

  create_table "ability_name", force: :cascade do |t|
    t.integer "ability_id", null: false
    t.datetime "created_at", null: false
    t.integer "local_language_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "ability_id", "local_language_id" ], name: "idx_ability_name_lookup"
    t.index [ "ability_id" ], name: "index_ability_name_on_ability_id"
    t.index [ "local_language_id" ], name: "index_ability_name_on_local_language_id"
  end

  create_table "ability_prose", force: :cascade do |t|
    t.integer "ability_id", null: false
    t.datetime "created_at", null: false
    t.text "effect"
    t.integer "local_language_id", null: false
    t.text "short_effect"
    t.datetime "updated_at", null: false
    t.index [ "ability_id", "local_language_id" ], name: "index_ability_prose_on_ability_id_and_local_language_id", unique: true
    t.index [ "local_language_id" ], name: "index_ability_prose_on_local_language_id"
  end

  create_table "berry", force: :cascade do |t|
    t.integer "berry_firmness_id"
    t.datetime "created_at", null: false
    t.integer "growth_time"
    t.integer "item_id"
    t.integer "max_harvest"
    t.string "name", null: false
    t.integer "natural_gift_power"
    t.integer "natural_gift_type_id"
    t.integer "size"
    t.integer "smoothness"
    t.integer "soil_dryness"
    t.datetime "updated_at", null: false
    t.index [ "berry_firmness_id" ], name: "index_berry_on_berry_firmness_id"
    t.index [ "item_id" ], name: "index_berry_on_item_id"
    t.index [ "name" ], name: "index_berry_on_name", unique: true
    t.index [ "natural_gift_type_id" ], name: "index_berry_on_natural_gift_type_id"
  end

  create_table "berry_firmness", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_berry_firmness_on_name", unique: true
  end

  create_table "berry_flavor", force: :cascade do |t|
    t.integer "contest_type_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "contest_type_id" ], name: "index_berry_flavor_on_contest_type_id"
    t.index [ "name" ], name: "index_berry_flavor_on_name", unique: true
  end

  create_table "characteristic", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "gene_mod_5"
    t.integer "stat_id"
    t.datetime "updated_at", null: false
    t.index [ "gene_mod_5" ], name: "index_characteristic_on_gene_mod_5"
    t.index [ "stat_id" ], name: "index_characteristic_on_stat_id"
  end

  create_table "contest_combo", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "first_move_id", null: false
    t.integer "second_move_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "first_move_id", "second_move_id" ], name: "index_contest_combo_on_first_move_id_and_second_move_id", unique: true
    t.index [ "second_move_id" ], name: "index_contest_combo_on_second_move_id"
  end

  create_table "contest_effect", force: :cascade do |t|
    t.integer "appeal"
    t.datetime "created_at", null: false
    t.integer "jam"
    t.datetime "updated_at", null: false
  end

  create_table "contest_type", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_contest_type_on_name", unique: true
  end

  create_table "egg_group", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_egg_group_on_name", unique: true
  end

  create_table "encounter", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "encounter_slot_id", null: false
    t.integer "location_area_id", null: false
    t.integer "max_level", null: false
    t.integer "min_level", null: false
    t.integer "pokemon_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_id", null: false
    t.index [ "encounter_slot_id" ], name: "index_encounter_on_encounter_slot_id"
    t.index [ "location_area_id" ], name: "index_encounter_on_location_area_id"
    t.index [ "pokemon_id" ], name: "index_encounter_on_pokemon_id"
    t.index [ "version_id" ], name: "index_encounter_on_version_id"
  end

  create_table "encounter_condition", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_encounter_condition_on_name", unique: true
  end

  create_table "encounter_condition_value", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "encounter_condition_id"
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "encounter_condition_id" ], name: "index_encounter_condition_value_on_encounter_condition_id"
    t.index [ "is_default" ], name: "index_encounter_condition_value_on_is_default"
    t.index [ "name" ], name: "index_encounter_condition_value_on_name", unique: true
  end

  create_table "encounter_condition_value_map", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "encounter_condition_value_id", null: false
    t.integer "encounter_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "encounter_condition_value_id" ], name: "idx_on_encounter_condition_value_id_4ec3d9ce2c"
    t.index [ "encounter_id", "encounter_condition_value_id" ], name: "idx_encounter_condition_value_map_unique", unique: true
  end

  create_table "encounter_method", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_encounter_method_on_name", unique: true
    t.index [ "sort_order" ], name: "index_encounter_method_on_sort_order"
  end

  create_table "encounter_slot", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "encounter_method_id", null: false
    t.integer "rarity", null: false
    t.integer "slot"
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "encounter_method_id" ], name: "index_encounter_slot_on_encounter_method_id"
    t.index [ "version_group_id", "encounter_method_id", "slot", "rarity" ], name: "idx_encounter_slot_lookup"
  end

  create_table "evolution_chain", force: :cascade do |t|
    t.integer "baby_trigger_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "baby_trigger_item_id" ], name: "index_evolution_chain_on_baby_trigger_item_id"
  end

  create_table "evolution_trigger", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_evolution_trigger_on_name", unique: true
  end

  create_table "gender", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_gender_on_name", unique: true
  end

  create_table "generation", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "main_region_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "main_region_id" ], name: "index_generation_on_main_region_id"
    t.index [ "name" ], name: "index_generation_on_name", unique: true
  end

  create_table "generation_name", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "generation_id", null: false
    t.integer "local_language_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id", "local_language_id" ], name: "index_generation_name_on_generation_id_and_local_language_id", unique: true
    t.index [ "local_language_id" ], name: "index_generation_name_on_local_language_id"
  end

  create_table "growth_rate", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "formula"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_growth_rate_on_name", unique: true
  end

  create_table "item", force: :cascade do |t|
    t.integer "category_id"
    t.integer "cost"
    t.datetime "created_at", null: false
    t.integer "fling_effect_id"
    t.integer "fling_power"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "category_id" ], name: "index_item_on_category_id"
    t.index [ "fling_effect_id" ], name: "index_item_on_fling_effect_id"
    t.index [ "name" ], name: "index_item_on_name"
  end

  create_table "item_attribute", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_item_attribute_on_name", unique: true
  end

  create_table "item_category", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "pocket_id"
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_item_category_on_name", unique: true
    t.index [ "pocket_id" ], name: "index_item_category_on_pocket_id"
  end

  create_table "item_flag_map", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_flag_id", null: false
    t.integer "item_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "item_flag_id" ], name: "index_item_flag_map_on_item_flag_id"
    t.index [ "item_id", "item_flag_id" ], name: "index_item_flag_map_on_item_id_and_item_flag_id", unique: true
  end

  create_table "item_flavor_text", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "flavor_text"
    t.integer "item_id", null: false
    t.integer "language_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "item_id", "version_group_id", "language_id" ], name: "idx_item_flavor_text_unique", unique: true
    t.index [ "language_id" ], name: "index_item_flavor_text_on_language_id"
    t.index [ "version_group_id" ], name: "index_item_flavor_text_on_version_group_id"
  end

  create_table "item_fling_effect", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_item_fling_effect_on_name", unique: true
  end

  create_table "item_game_index", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_index", null: false
    t.integer "generation_id", null: false
    t.integer "item_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_item_game_index_on_generation_id"
    t.index [ "item_id", "generation_id" ], name: "index_item_game_index_on_item_id_and_generation_id", unique: true
  end

  create_table "item_name", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.integer "local_language_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "item_id", "local_language_id" ], name: "index_item_name_on_item_id_and_local_language_id", unique: true
    t.index [ "local_language_id" ], name: "index_item_name_on_local_language_id"
  end

  create_table "item_pocket", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_item_pocket_on_name", unique: true
  end

  create_table "item_prose", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "effect"
    t.integer "item_id", null: false
    t.integer "local_language_id", null: false
    t.text "short_effect"
    t.datetime "updated_at", null: false
    t.index [ "item_id", "local_language_id" ], name: "index_item_prose_on_item_id_and_local_language_id", unique: true
    t.index [ "local_language_id" ], name: "index_item_prose_on_local_language_id"
  end

  create_table "language", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "iso3166"
    t.string "iso639"
    t.string "name", null: false
    t.boolean "official", default: false, null: false
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.index [ "iso3166" ], name: "index_language_on_iso3166"
    t.index [ "iso639" ], name: "index_language_on_iso639"
    t.index [ "name" ], name: "index_language_on_name", unique: true
    t.index [ "official" ], name: "index_language_on_official"
    t.index [ "sort_order" ], name: "index_language_on_sort_order"
  end

  create_table "location", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "region_id"
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_location_on_name", unique: true
    t.index [ "region_id" ], name: "index_location_on_region_id"
  end

  create_table "location_area", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_index"
    t.integer "location_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "game_index" ], name: "index_location_area_on_game_index"
    t.index [ "location_id" ], name: "index_location_area_on_location_id"
    t.index [ "name" ], name: "index_location_area_on_name", unique: true
  end

  create_table "location_game_index", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_index", null: false
    t.integer "generation_id", null: false
    t.integer "location_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_location_game_index_on_generation_id"
    t.index [ "location_id", "generation_id", "game_index" ], name: "idx_location_game_index_unique", unique: true
  end

  create_table "location_name", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "local_language_id", null: false
    t.integer "location_id", null: false
    t.string "name"
    t.string "subtitle"
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_location_name_on_local_language_id"
    t.index [ "location_id", "local_language_id" ], name: "index_location_name_on_location_id_and_local_language_id", unique: true
  end

  create_table "machine", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_id"
    t.integer "machine_number"
    t.integer "move_id"
    t.datetime "updated_at", null: false
    t.integer "version_group_id"
    t.index [ "item_id" ], name: "index_machine_on_item_id"
    t.index [ "machine_number", "version_group_id" ], name: "index_machine_on_machine_number_and_version_group_id", unique: true
    t.index [ "machine_number" ], name: "index_machine_on_machine_number"
    t.index [ "move_id" ], name: "index_machine_on_move_id"
    t.index [ "version_group_id" ], name: "index_machine_on_version_group_id"
  end

  create_table "move", force: :cascade do |t|
    t.integer "accuracy"
    t.integer "contest_effect_id"
    t.integer "contest_type_id"
    t.datetime "created_at", null: false
    t.integer "damage_class_id"
    t.integer "effect_chance"
    t.integer "effect_id"
    t.integer "generation_id"
    t.string "name", null: false
    t.integer "power"
    t.integer "pp"
    t.integer "priority"
    t.integer "super_contest_effect_id"
    t.integer "target_id"
    t.integer "type_id"
    t.datetime "updated_at", null: false
    t.index [ "contest_effect_id" ], name: "index_move_on_contest_effect_id"
    t.index [ "contest_type_id" ], name: "index_move_on_contest_type_id"
    t.index [ "damage_class_id" ], name: "index_move_on_damage_class_id"
    t.index [ "generation_id" ], name: "index_move_on_generation_id"
    t.index [ "name" ], name: "index_move_on_name", unique: true
    t.index [ "super_contest_effect_id" ], name: "index_move_on_super_contest_effect_id"
    t.index [ "target_id" ], name: "index_move_on_target_id"
    t.index [ "type_id" ], name: "index_move_on_type_id"
  end

  create_table "move_ailment", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_move_ailment_on_name", unique: true
  end

  create_table "move_battle_style", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_move_battle_style_on_name", unique: true
  end

  create_table "move_changelog", force: :cascade do |t|
    t.integer "accuracy"
    t.integer "changed_in_version_group_id", null: false
    t.datetime "created_at", null: false
    t.integer "effect_chance"
    t.integer "effect_id"
    t.integer "move_id", null: false
    t.integer "power"
    t.integer "pp"
    t.integer "priority"
    t.integer "target_id"
    t.integer "type_id"
    t.datetime "updated_at", null: false
    t.index [ "changed_in_version_group_id" ], name: "index_move_changelog_on_changed_in_version_group_id"
    t.index [ "move_id", "changed_in_version_group_id" ], name: "idx_move_changelog_unique", unique: true
    t.index [ "type_id" ], name: "index_move_changelog_on_type_id"
  end

  create_table "move_damage_class", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_move_damage_class_on_name", unique: true
  end

  create_table "move_effect_changelog", force: :cascade do |t|
    t.integer "changed_in_version_group_id", null: false
    t.datetime "created_at", null: false
    t.integer "effect_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "changed_in_version_group_id" ], name: "index_move_effect_changelog_on_changed_in_version_group_id"
    t.index [ "effect_id" ], name: "index_move_effect_changelog_on_effect_id"
  end

  create_table "move_effect_changelog_prose", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "effect"
    t.integer "local_language_id", null: false
    t.integer "move_effect_changelog_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_move_effect_changelog_prose_on_local_language_id"
    t.index [ "move_effect_changelog_id", "local_language_id" ], name: "idx_move_effect_changelog_prose_unique", unique: true
  end

  create_table "move_effect_prose", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "effect"
    t.integer "local_language_id", null: false
    t.integer "move_effect_id", null: false
    t.text "short_effect"
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_move_effect_prose_on_local_language_id"
    t.index [ "move_effect_id", "local_language_id" ], name: "idx_on_move_effect_id_local_language_id_a16f74b628", unique: true
  end

  create_table "move_flavor_text", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "flavor_text"
    t.integer "language_id", null: false
    t.integer "move_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "language_id" ], name: "index_move_flavor_text_on_language_id"
    t.index [ "move_id", "version_group_id", "language_id" ], name: "idx_move_flavor_text_lookup"
    t.index [ "move_id" ], name: "index_move_flavor_text_on_move_id"
    t.index [ "version_group_id" ], name: "index_move_flavor_text_on_version_group_id"
  end

  create_table "move_learn_method", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_move_learn_method_on_name", unique: true
  end

  create_table "move_meta", force: :cascade do |t|
    t.integer "ailment_chance"
    t.datetime "created_at", null: false
    t.integer "crit_rate"
    t.integer "drain"
    t.integer "flinch_chance"
    t.integer "healing"
    t.integer "max_hits"
    t.integer "max_turns"
    t.integer "meta_ailment_id"
    t.integer "meta_category_id"
    t.integer "min_hits"
    t.integer "min_turns"
    t.integer "move_id", null: false
    t.integer "stat_chance"
    t.datetime "updated_at", null: false
    t.index [ "meta_ailment_id" ], name: "index_move_meta_on_meta_ailment_id"
    t.index [ "meta_category_id" ], name: "index_move_meta_on_meta_category_id"
    t.index [ "move_id" ], name: "index_move_meta_on_move_id", unique: true
  end

  create_table "move_meta_category", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_move_meta_category_on_name", unique: true
  end

  create_table "move_meta_stat_change", force: :cascade do |t|
    t.integer "change", null: false
    t.datetime "created_at", null: false
    t.integer "move_id", null: false
    t.integer "stat_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "move_id", "stat_id", "change" ], name: "idx_move_meta_stat_change_unique", unique: true
    t.index [ "stat_id" ], name: "index_move_meta_stat_change_on_stat_id"
  end

  create_table "move_name", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "local_language_id", null: false
    t.integer "move_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_move_name_on_local_language_id"
    t.index [ "move_id", "local_language_id" ], name: "index_move_name_on_move_id_and_local_language_id", unique: true
  end

  create_table "move_target", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_move_target_on_name", unique: true
  end

  create_table "nature", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "decreased_stat_id"
    t.integer "game_index"
    t.integer "hates_flavor_id"
    t.integer "increased_stat_id"
    t.integer "likes_flavor_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "decreased_stat_id" ], name: "index_nature_on_decreased_stat_id"
    t.index [ "game_index" ], name: "index_nature_on_game_index"
    t.index [ "hates_flavor_id" ], name: "index_nature_on_hates_flavor_id"
    t.index [ "increased_stat_id" ], name: "index_nature_on_increased_stat_id"
    t.index [ "likes_flavor_id" ], name: "index_nature_on_likes_flavor_id"
    t.index [ "name" ], name: "index_nature_on_name", unique: true
  end

  create_table "pal_park", force: :cascade do |t|
    t.integer "area_id", null: false
    t.integer "base_score", null: false
    t.datetime "created_at", null: false
    t.integer "rate", null: false
    t.integer "species_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "area_id" ], name: "index_pal_park_on_area_id"
    t.index [ "species_id", "area_id" ], name: "index_pal_park_on_species_id_and_area_id", unique: true
  end

  create_table "pal_park_area", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_pal_park_area_on_name", unique: true
  end

  create_table "pokeathlon_stat", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_pokeathlon_stat_on_name", unique: true
  end

  create_table "pokedex", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_main_series", default: true, null: false
    t.string "name", null: false
    t.integer "region_id"
    t.datetime "updated_at", null: false
    t.index [ "is_main_series" ], name: "index_pokedex_on_is_main_series"
    t.index [ "name" ], name: "index_pokedex_on_name", unique: true
    t.index [ "region_id" ], name: "index_pokedex_on_region_id"
  end

  create_table "pokedex_version_group", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pokedex_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "pokedex_id", "version_group_id" ], name: "index_pokedex_version_group_on_pokedex_id_and_version_group_id", unique: true
    t.index [ "version_group_id" ], name: "index_pokedex_version_group_on_version_group_id"
  end

  create_table "pokemon", force: :cascade do |t|
    t.integer "base_experience"
    t.datetime "created_at", null: false
    t.integer "height"
    t.boolean "is_default"
    t.string "name", null: false
    t.integer "sort_order"
    t.integer "species_id"
    t.datetime "updated_at", null: false
    t.integer "weight"
    t.index [ "is_default" ], name: "index_pokemon_on_is_default"
    t.index [ "name" ], name: "index_pokemon_on_name", unique: true
    t.index [ "sort_order" ], name: "index_pokemon_on_sort_order"
    t.index [ "species_id" ], name: "index_pokemon_on_species_id"
  end

  create_table "pokemon_ability", force: :cascade do |t|
    t.integer "ability_id", null: false
    t.datetime "created_at", null: false
    t.boolean "is_hidden", default: false, null: false
    t.integer "pokemon_id", null: false
    t.integer "slot", null: false
    t.datetime "updated_at", null: false
    t.index [ "ability_id" ], name: "index_pokemon_ability_on_ability_id"
    t.index [ "pokemon_id", "slot", "ability_id" ], name: "idx_pokemon_ability_on_pokemon_slot_ability", unique: true
  end

  create_table "pokemon_ability_past", force: :cascade do |t|
    t.integer "ability_id"
    t.datetime "created_at", null: false
    t.integer "generation_id", null: false
    t.boolean "is_hidden", default: false, null: false
    t.integer "pokemon_id", null: false
    t.integer "slot", null: false
    t.datetime "updated_at", null: false
    t.index [ "ability_id" ], name: "index_pokemon_ability_past_on_ability_id"
    t.index [ "generation_id" ], name: "index_pokemon_ability_past_on_generation_id"
    t.index [ "pokemon_id", "generation_id", "slot" ], name: "idx_pokemon_ability_past_on_pokemon_generation_slot", unique: true
  end

  create_table "pokemon_color", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_pokemon_color_on_name", unique: true
  end

  create_table "pokemon_dex_number", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pokedex_id", null: false
    t.integer "pokedex_number", null: false
    t.integer "species_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "pokedex_id" ], name: "index_pokemon_dex_number_on_pokedex_id"
    t.index [ "species_id", "pokedex_id" ], name: "index_pokemon_dex_number_on_species_id_and_pokedex_id", unique: true
  end

  create_table "pokemon_egg_group", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "egg_group_id", null: false
    t.integer "species_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "egg_group_id" ], name: "index_pokemon_egg_group_on_egg_group_id"
    t.index [ "species_id", "egg_group_id" ], name: "index_pokemon_egg_group_on_species_id_and_egg_group_id", unique: true
  end

  create_table "pokemon_form", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "form_name"
    t.integer "form_order"
    t.integer "introduced_in_version_group_id"
    t.boolean "is_battle_only", default: false, null: false
    t.boolean "is_default", default: false, null: false
    t.boolean "is_mega", default: false, null: false
    t.string "name", null: false
    t.integer "pokemon_id"
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.index [ "form_order" ], name: "index_pokemon_form_on_form_order"
    t.index [ "introduced_in_version_group_id" ], name: "index_pokemon_form_on_introduced_in_version_group_id"
    t.index [ "is_battle_only" ], name: "index_pokemon_form_on_is_battle_only"
    t.index [ "is_default" ], name: "index_pokemon_form_on_is_default"
    t.index [ "is_mega" ], name: "index_pokemon_form_on_is_mega"
    t.index [ "name" ], name: "index_pokemon_form_on_name", unique: true
    t.index [ "pokemon_id" ], name: "index_pokemon_form_on_pokemon_id"
    t.index [ "sort_order" ], name: "index_pokemon_form_on_sort_order"
  end

  create_table "pokemon_game_index", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_index", null: false
    t.integer "pokemon_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_id", null: false
    t.index [ "pokemon_id", "version_id" ], name: "index_pokemon_game_index_on_pokemon_id_and_version_id", unique: true
    t.index [ "version_id" ], name: "index_pokemon_game_index_on_version_id"
  end

  create_table "pokemon_habitat", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_pokemon_habitat_on_name", unique: true
  end

  create_table "pokemon_item", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.integer "pokemon_id", null: false
    t.integer "rarity", null: false
    t.datetime "updated_at", null: false
    t.integer "version_id", null: false
    t.index [ "item_id" ], name: "index_pokemon_item_on_item_id"
    t.index [ "pokemon_id", "item_id", "version_id" ], name: "idx_pokemon_item_on_pokemon_item_version", unique: true
    t.index [ "version_id" ], name: "index_pokemon_item_on_version_id"
  end

  create_table "pokemon_move", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "level", null: false
    t.integer "mastery"
    t.integer "move_id", null: false
    t.integer "pokemon_id", null: false
    t.integer "pokemon_move_method_id", null: false
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "move_id" ], name: "index_pokemon_move_on_move_id"
    t.index [ "pokemon_id", "move_id", "version_group_id", "pokemon_move_method_id", "level" ], name: "idx_pokemon_move_uniqueness", unique: true
    t.index [ "pokemon_move_method_id" ], name: "index_pokemon_move_on_pokemon_move_method_id"
    t.index [ "version_group_id" ], name: "index_pokemon_move_on_version_group_id"
  end

  create_table "pokemon_shape", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_pokemon_shape_on_name", unique: true
  end

  create_table "pokemon_species", force: :cascade do |t|
    t.integer "base_happiness"
    t.integer "capture_rate"
    t.integer "color_id"
    t.integer "conquest_order"
    t.datetime "created_at", null: false
    t.integer "evolution_chain_id"
    t.integer "evolves_from_species_id"
    t.boolean "forms_switchable", default: false, null: false
    t.integer "gender_rate"
    t.integer "generation_id"
    t.integer "growth_rate_id"
    t.integer "habitat_id"
    t.boolean "has_gender_differences", default: false, null: false
    t.integer "hatch_counter"
    t.boolean "is_baby", default: false, null: false
    t.boolean "is_legendary", default: false, null: false
    t.boolean "is_mythical", default: false, null: false
    t.string "name", null: false
    t.integer "shape_id"
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.index [ "color_id" ], name: "index_pokemon_species_on_color_id"
    t.index [ "conquest_order" ], name: "index_pokemon_species_on_conquest_order"
    t.index [ "evolution_chain_id" ], name: "index_pokemon_species_on_evolution_chain_id"
    t.index [ "evolves_from_species_id" ], name: "index_pokemon_species_on_evolves_from_species_id"
    t.index [ "forms_switchable" ], name: "index_pokemon_species_on_forms_switchable"
    t.index [ "generation_id" ], name: "index_pokemon_species_on_generation_id"
    t.index [ "growth_rate_id" ], name: "index_pokemon_species_on_growth_rate_id"
    t.index [ "habitat_id" ], name: "index_pokemon_species_on_habitat_id"
    t.index [ "has_gender_differences" ], name: "index_pokemon_species_on_has_gender_differences"
    t.index [ "is_baby" ], name: "index_pokemon_species_on_is_baby"
    t.index [ "is_legendary" ], name: "index_pokemon_species_on_is_legendary"
    t.index [ "is_mythical" ], name: "index_pokemon_species_on_is_mythical"
    t.index [ "name" ], name: "index_pokemon_species_on_name", unique: true
    t.index [ "shape_id" ], name: "index_pokemon_species_on_shape_id"
    t.index [ "sort_order" ], name: "index_pokemon_species_on_sort_order"
  end

  create_table "pokemon_species_flavor_text", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "flavor_text"
    t.integer "language_id", null: false
    t.integer "species_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_id", null: false
    t.index [ "language_id" ], name: "index_pokemon_species_flavor_text_on_language_id"
    t.index [ "species_id", "version_id", "language_id" ], name: "idx_pokemon_species_flavor_text_unique", unique: true
    t.index [ "version_id" ], name: "index_pokemon_species_flavor_text_on_version_id"
  end

  create_table "pokemon_species_name", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "genus"
    t.integer "local_language_id", null: false
    t.string "name"
    t.integer "pokemon_species_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_pokemon_species_name_on_local_language_id"
    t.index [ "pokemon_species_id", "local_language_id" ], name: "idx_pokemon_species_name_unique", unique: true
  end

  create_table "pokemon_species_prose", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "form_description"
    t.integer "local_language_id", null: false
    t.integer "pokemon_species_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_pokemon_species_prose_on_local_language_id"
    t.index [ "pokemon_species_id", "local_language_id" ], name: "idx_pokemon_species_prose_unique", unique: true
  end

  create_table "pokemon_stat", force: :cascade do |t|
    t.integer "base_stat", null: false
    t.datetime "created_at", null: false
    t.integer "effort", null: false
    t.integer "pokemon_id", null: false
    t.integer "stat_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "pokemon_id", "stat_id" ], name: "index_pokemon_stat_on_pokemon_id_and_stat_id", unique: true
    t.index [ "stat_id" ], name: "index_pokemon_stat_on_stat_id"
  end

  create_table "pokemon_stat_past", force: :cascade do |t|
    t.integer "base_stat", null: false
    t.datetime "created_at", null: false
    t.integer "effort", null: false
    t.integer "generation_id", null: false
    t.integer "pokemon_id", null: false
    t.integer "stat_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_pokemon_stat_past_on_generation_id"
    t.index [ "pokemon_id", "generation_id", "stat_id" ], name: "idx_pokemon_stat_past_on_pokemon_generation_stat", unique: true
    t.index [ "stat_id" ], name: "index_pokemon_stat_past_on_stat_id"
  end

  create_table "pokemon_type", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pokemon_id", null: false
    t.integer "slot", null: false
    t.integer "type_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "pokemon_id", "slot" ], name: "index_pokemon_type_on_pokemon_id_and_slot", unique: true
    t.index [ "type_id" ], name: "index_pokemon_type_on_type_id"
  end

  create_table "pokemon_type_past", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "generation_id", null: false
    t.integer "pokemon_id", null: false
    t.integer "slot", null: false
    t.integer "type_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_pokemon_type_past_on_generation_id"
    t.index [ "pokemon_id", "generation_id", "slot" ], name: "idx_pokemon_type_past_on_pokemon_generation_slot", unique: true
    t.index [ "type_id" ], name: "index_pokemon_type_past_on_type_id"
  end

  create_table "region", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_region_on_name", unique: true
  end

  create_table "stat", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "damage_class_id"
    t.integer "game_index"
    t.boolean "is_battle_only", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "damage_class_id" ], name: "index_stat_on_damage_class_id"
    t.index [ "game_index" ], name: "index_stat_on_game_index"
    t.index [ "is_battle_only" ], name: "index_stat_on_is_battle_only"
    t.index [ "name" ], name: "index_stat_on_name", unique: true
  end

  create_table "super_contest_combo", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "first_move_id", null: false
    t.integer "second_move_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "first_move_id", "second_move_id" ], name: "index_super_contest_combo_on_first_move_id_and_second_move_id", unique: true
    t.index [ "second_move_id" ], name: "index_super_contest_combo_on_second_move_id"
  end

  create_table "super_contest_effect", force: :cascade do |t|
    t.integer "appeal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "type", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "damage_class_id"
    t.integer "generation_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index [ "damage_class_id" ], name: "index_type_on_damage_class_id"
    t.index [ "generation_id" ], name: "index_type_on_generation_id"
    t.index [ "name" ], name: "index_type_on_name", unique: true
  end

  create_table "type_efficacy", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "damage_factor", null: false
    t.integer "damage_type_id", null: false
    t.integer "target_type_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "damage_type_id", "target_type_id" ], name: "index_type_efficacy_on_damage_type_id_and_target_type_id", unique: true
    t.index [ "target_type_id" ], name: "index_type_efficacy_on_target_type_id"
  end

  create_table "type_efficacy_past", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "damage_factor", null: false
    t.integer "damage_type_id", null: false
    t.integer "generation_id", null: false
    t.integer "target_type_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "damage_type_id", "target_type_id", "generation_id" ], name: "idx_type_efficacy_past_unique", unique: true
    t.index [ "generation_id" ], name: "index_type_efficacy_past_on_generation_id"
    t.index [ "target_type_id" ], name: "index_type_efficacy_past_on_target_type_id"
  end

  create_table "type_game_index", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_index", null: false
    t.integer "generation_id", null: false
    t.integer "type_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_type_game_index_on_generation_id"
    t.index [ "type_id", "generation_id" ], name: "index_type_game_index_on_type_id_and_generation_id", unique: true
  end

  create_table "type_name", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "local_language_id", null: false
    t.string "name", null: false
    t.integer "type_id", null: false
    t.datetime "updated_at", null: false
    t.index [ "local_language_id" ], name: "index_type_name_on_local_language_id"
    t.index [ "type_id", "local_language_id" ], name: "index_type_name_on_type_id_and_local_language_id", unique: true
  end

  create_table "version", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id"
    t.index [ "name" ], name: "index_version_on_name", unique: true
    t.index [ "version_group_id" ], name: "index_version_on_version_group_id"
  end

  create_table "version_group", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "generation_id"
    t.string "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", null: false
    t.index [ "generation_id" ], name: "index_version_group_on_generation_id"
    t.index [ "name" ], name: "index_version_group_on_name", unique: true
    t.index [ "sort_order" ], name: "index_version_group_on_sort_order"
  end

  create_table "version_group_pokemon_move_method", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pokemon_move_method_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "pokemon_move_method_id" ], name: "idx_on_pokemon_move_method_id_f7fde217e7"
    t.index [ "version_group_id", "pokemon_move_method_id" ], name: "idx_vg_pokemon_move_method_unique", unique: true
  end

  create_table "version_group_region", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "region_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version_group_id", null: false
    t.index [ "region_id" ], name: "index_version_group_region_on_region_id"
    t.index [ "version_group_id", "region_id" ], name: "index_version_group_region_on_version_group_id_and_region_id", unique: true
  end
end
