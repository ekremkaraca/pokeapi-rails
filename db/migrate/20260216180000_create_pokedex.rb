class CreatePokedex < ActiveRecord::Migration[8.1]
  def change
    create_table :pokedex do |t|
      t.string :name, null: false
      t.integer :region_id
      t.boolean :is_main_series, null: false, default: true

      t.timestamps
    end

    add_index :pokedex, :name, unique: true
    add_index :pokedex, :region_id
    add_index :pokedex, :is_main_series
  end
end
