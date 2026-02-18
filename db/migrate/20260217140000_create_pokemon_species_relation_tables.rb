class CreatePokemonSpeciesRelationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_egg_group do |t|
      t.integer :species_id, null: false
      t.integer :egg_group_id, null: false

      t.timestamps
    end
    add_index :pokemon_egg_group, [ :species_id, :egg_group_id ], unique: true
    add_index :pokemon_egg_group, :egg_group_id

    create_table :pokemon_species_name do |t|
      t.integer :pokemon_species_id, null: false
      t.integer :local_language_id, null: false
      t.string :name
      t.string :genus

      t.timestamps
    end
    add_index :pokemon_species_name, [ :pokemon_species_id, :local_language_id ], unique: true, name: "idx_pokemon_species_name_unique"
    add_index :pokemon_species_name, :local_language_id

    create_table :pokemon_species_flavor_text do |t|
      t.integer :species_id, null: false
      t.integer :version_id, null: false
      t.integer :language_id, null: false
      t.text :flavor_text

      t.timestamps
    end
    add_index :pokemon_species_flavor_text, [ :species_id, :version_id, :language_id ], unique: true, name: "idx_pokemon_species_flavor_text_unique"
    add_index :pokemon_species_flavor_text, :version_id
    add_index :pokemon_species_flavor_text, :language_id

    create_table :pokemon_species_prose do |t|
      t.integer :pokemon_species_id, null: false
      t.integer :local_language_id, null: false
      t.text :form_description

      t.timestamps
    end
    add_index :pokemon_species_prose, [ :pokemon_species_id, :local_language_id ], unique: true, name: "idx_pokemon_species_prose_unique"
    add_index :pokemon_species_prose, :local_language_id

    create_table :pal_park do |t|
      t.integer :species_id, null: false
      t.integer :area_id, null: false
      t.integer :base_score, null: false
      t.integer :rate, null: false

      t.timestamps
    end
    add_index :pal_park, [ :species_id, :area_id ], unique: true
    add_index :pal_park, :area_id

    create_table :pokemon_dex_number do |t|
      t.integer :species_id, null: false
      t.integer :pokedex_id, null: false
      t.integer :pokedex_number, null: false

      t.timestamps
    end
    add_index :pokemon_dex_number, [ :species_id, :pokedex_id ], unique: true
    add_index :pokemon_dex_number, :pokedex_id
  end
end
