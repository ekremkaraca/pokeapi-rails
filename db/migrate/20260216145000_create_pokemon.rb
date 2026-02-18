class CreatePokemon < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pokemon, :name, unique: true
  end
end
