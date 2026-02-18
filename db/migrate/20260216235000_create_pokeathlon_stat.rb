class CreatePokeathlonStat < ActiveRecord::Migration[8.1]
  def change
    create_table :pokeathlon_stat do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pokeathlon_stat, :name, unique: true
  end
end
