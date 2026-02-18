class CreatePokemonSpecies < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_species do |t|
      t.string :name, null: false
      t.integer :generation_id
      t.integer :evolves_from_species_id
      t.integer :evolution_chain_id
      t.integer :color_id
      t.integer :shape_id
      t.integer :habitat_id
      t.integer :gender_rate
      t.integer :capture_rate
      t.integer :base_happiness
      t.boolean :is_baby, null: false, default: false
      t.integer :hatch_counter
      t.boolean :has_gender_differences, null: false, default: false
      t.integer :growth_rate_id
      t.boolean :forms_switchable, null: false, default: false
      t.boolean :is_legendary, null: false, default: false
      t.boolean :is_mythical, null: false, default: false
      t.integer :sort_order
      t.integer :conquest_order

      t.timestamps
    end

    add_index :pokemon_species, :name, unique: true
    add_index :pokemon_species, :generation_id
    add_index :pokemon_species, :evolves_from_species_id
    add_index :pokemon_species, :evolution_chain_id
    add_index :pokemon_species, :color_id
    add_index :pokemon_species, :shape_id
    add_index :pokemon_species, :habitat_id
    add_index :pokemon_species, :growth_rate_id
    add_index :pokemon_species, :is_baby
    add_index :pokemon_species, :has_gender_differences
    add_index :pokemon_species, :forms_switchable
    add_index :pokemon_species, :is_legendary
    add_index :pokemon_species, :is_mythical
    add_index :pokemon_species, :sort_order
    add_index :pokemon_species, :conquest_order
  end
end
