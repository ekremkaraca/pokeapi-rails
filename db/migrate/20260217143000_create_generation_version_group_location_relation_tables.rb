class CreateGenerationVersionGroupLocationRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :generation_name do |t|
      t.integer :generation_id, null: false
      t.integer :local_language_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :generation_name, [ :generation_id, :local_language_id ], unique: true
    add_index :generation_name, :local_language_id

    create_table :version_group_pokemon_move_method do |t|
      t.integer :version_group_id, null: false
      t.integer :pokemon_move_method_id, null: false

      t.timestamps
    end
    add_index :version_group_pokemon_move_method, [ :version_group_id, :pokemon_move_method_id ], unique: true, name: "idx_vg_pokemon_move_method_unique"
    add_index :version_group_pokemon_move_method, :pokemon_move_method_id

    create_table :pokedex_version_group do |t|
      t.integer :pokedex_id, null: false
      t.integer :version_group_id, null: false

      t.timestamps
    end
    add_index :pokedex_version_group, [ :pokedex_id, :version_group_id ], unique: true
    add_index :pokedex_version_group, :version_group_id

    create_table :version_group_region do |t|
      t.integer :version_group_id, null: false
      t.integer :region_id, null: false

      t.timestamps
    end
    add_index :version_group_region, [ :version_group_id, :region_id ], unique: true
    add_index :version_group_region, :region_id

    create_table :location_game_index do |t|
      t.integer :location_id, null: false
      t.integer :generation_id, null: false
      t.integer :game_index, null: false

      t.timestamps
    end
    add_index :location_game_index, [ :location_id, :generation_id, :game_index ], unique: true, name: "idx_location_game_index_unique"
    add_index :location_game_index, :generation_id

    create_table :location_name do |t|
      t.integer :location_id, null: false
      t.integer :local_language_id, null: false
      t.string :name
      t.string :subtitle

      t.timestamps
    end
    add_index :location_name, [ :location_id, :local_language_id ], unique: true
    add_index :location_name, :local_language_id
  end
end
