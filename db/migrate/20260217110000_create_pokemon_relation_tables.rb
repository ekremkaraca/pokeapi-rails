class CreatePokemonRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_ability do |t|
      t.integer :pokemon_id, null: false
      t.integer :ability_id, null: false
      t.boolean :is_hidden, null: false, default: false
      t.integer :slot, null: false

      t.timestamps
    end
    add_index :pokemon_ability, [ :pokemon_id, :slot, :ability_id ], unique: true, name: "idx_pokemon_ability_on_pokemon_slot_ability"
    add_index :pokemon_ability, :ability_id

    create_table :pokemon_ability_past do |t|
      t.integer :pokemon_id, null: false
      t.integer :generation_id, null: false
      t.integer :ability_id
      t.boolean :is_hidden, null: false, default: false
      t.integer :slot, null: false

      t.timestamps
    end
    add_index :pokemon_ability_past, [ :pokemon_id, :generation_id, :slot ], unique: true, name: "idx_pokemon_ability_past_on_pokemon_generation_slot"
    add_index :pokemon_ability_past, :ability_id
    add_index :pokemon_ability_past, :generation_id

    create_table :pokemon_game_index do |t|
      t.integer :pokemon_id, null: false
      t.integer :version_id, null: false
      t.integer :game_index, null: false

      t.timestamps
    end
    add_index :pokemon_game_index, [ :pokemon_id, :version_id ], unique: true
    add_index :pokemon_game_index, :version_id

    create_table :pokemon_item do |t|
      t.integer :pokemon_id, null: false
      t.integer :version_id, null: false
      t.integer :item_id, null: false
      t.integer :rarity, null: false

      t.timestamps
    end
    add_index :pokemon_item, [ :pokemon_id, :item_id, :version_id ], unique: true, name: "idx_pokemon_item_on_pokemon_item_version"
    add_index :pokemon_item, :item_id
    add_index :pokemon_item, :version_id

    create_table :pokemon_move do |t|
      t.integer :pokemon_id, null: false
      t.integer :version_group_id, null: false
      t.integer :move_id, null: false
      t.integer :pokemon_move_method_id, null: false
      t.integer :level, null: false
      t.integer :sort_order
      t.integer :mastery

      t.timestamps
    end
    add_index :pokemon_move, [ :pokemon_id, :move_id, :version_group_id, :pokemon_move_method_id, :level ], unique: true, name: "idx_pokemon_move_uniqueness"
    add_index :pokemon_move, :move_id
    add_index :pokemon_move, :version_group_id
    add_index :pokemon_move, :pokemon_move_method_id

    create_table :pokemon_stat do |t|
      t.integer :pokemon_id, null: false
      t.integer :stat_id, null: false
      t.integer :base_stat, null: false
      t.integer :effort, null: false

      t.timestamps
    end
    add_index :pokemon_stat, [ :pokemon_id, :stat_id ], unique: true
    add_index :pokemon_stat, :stat_id

    create_table :pokemon_stat_past do |t|
      t.integer :pokemon_id, null: false
      t.integer :generation_id, null: false
      t.integer :stat_id, null: false
      t.integer :base_stat, null: false
      t.integer :effort, null: false

      t.timestamps
    end
    add_index :pokemon_stat_past, [ :pokemon_id, :generation_id, :stat_id ], unique: true, name: "idx_pokemon_stat_past_on_pokemon_generation_stat"
    add_index :pokemon_stat_past, :generation_id
    add_index :pokemon_stat_past, :stat_id

    create_table :pokemon_type do |t|
      t.integer :pokemon_id, null: false
      t.integer :type_id, null: false
      t.integer :slot, null: false

      t.timestamps
    end
    add_index :pokemon_type, [ :pokemon_id, :slot ], unique: true
    add_index :pokemon_type, :type_id

    create_table :pokemon_type_past do |t|
      t.integer :pokemon_id, null: false
      t.integer :generation_id, null: false
      t.integer :type_id, null: false
      t.integer :slot, null: false

      t.timestamps
    end
    add_index :pokemon_type_past, [ :pokemon_id, :generation_id, :slot ], unique: true, name: "idx_pokemon_type_past_on_pokemon_generation_slot"
    add_index :pokemon_type_past, :generation_id
    add_index :pokemon_type_past, :type_id
  end
end
