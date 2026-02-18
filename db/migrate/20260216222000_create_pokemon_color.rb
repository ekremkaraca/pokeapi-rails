class CreatePokemonColor < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_color do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pokemon_color, :name, unique: true
  end
end
