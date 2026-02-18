class CreateLocationArea < ActiveRecord::Migration[8.1]
  def change
    create_table :location_area do |t|
      t.string :name, null: false
      t.integer :location_id
      t.integer :game_index

      t.timestamps
    end

    add_index :location_area, :name, unique: true
    add_index :location_area, :location_id
    add_index :location_area, :game_index
  end
end
