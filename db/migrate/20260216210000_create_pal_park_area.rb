class CreatePalParkArea < ActiveRecord::Migration[8.1]
  def change
    create_table :pal_park_area do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :pal_park_area, :name, unique: true
  end
end
