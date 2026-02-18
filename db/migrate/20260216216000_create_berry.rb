class CreateBerry < ActiveRecord::Migration[8.1]
  def change
    create_table :berry do |t|
      t.string :name, null: false
      t.integer :item_id
      t.integer :berry_firmness_id
      t.integer :natural_gift_power
      t.integer :natural_gift_type_id
      t.integer :size
      t.integer :max_harvest
      t.integer :growth_time
      t.integer :soil_dryness
      t.integer :smoothness

      t.timestamps
    end

    add_index :berry, :name, unique: true
    add_index :berry, :item_id
    add_index :berry, :berry_firmness_id
    add_index :berry, :natural_gift_type_id
  end
end
