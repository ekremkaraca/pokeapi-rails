class CreatePokemonShape < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_shape do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pokemon_shape, :name, unique: true
  end
end
