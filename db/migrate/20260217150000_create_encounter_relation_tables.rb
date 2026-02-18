class CreateEncounterRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :encounter do |t|
      t.integer :version_id, null: false
      t.integer :location_area_id, null: false
      t.integer :encounter_slot_id, null: false
      t.integer :pokemon_id, null: false
      t.integer :min_level, null: false
      t.integer :max_level, null: false

      t.timestamps
    end
    add_index :encounter, :version_id
    add_index :encounter, :location_area_id
    add_index :encounter, :encounter_slot_id
    add_index :encounter, :pokemon_id

    create_table :encounter_slot do |t|
      t.integer :version_group_id, null: false
      t.integer :encounter_method_id, null: false
      t.integer :slot
      t.integer :rarity, null: false

      t.timestamps
    end
    add_index :encounter_slot, [ :version_group_id, :encounter_method_id, :slot, :rarity ], name: "idx_encounter_slot_lookup"
    add_index :encounter_slot, :encounter_method_id

    create_table :encounter_condition_value_map do |t|
      t.integer :encounter_id, null: false
      t.integer :encounter_condition_value_id, null: false

      t.timestamps
    end
    add_index :encounter_condition_value_map, [ :encounter_id, :encounter_condition_value_id ], unique: true, name: "idx_encounter_condition_value_map_unique"
    add_index :encounter_condition_value_map, :encounter_condition_value_id
  end
end
