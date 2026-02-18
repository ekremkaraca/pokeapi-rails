class CreatePokemonHabitat < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_habitat do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pokemon_habitat, :name, unique: true
  end
end
