class CreateItem < ActiveRecord::Migration[8.1]
  def change
    create_table :item do |t|
      t.string :name, null: false
      t.integer :category_id
      t.integer :cost
      t.integer :fling_power
      t.integer :fling_effect_id

      t.timestamps
    end

    add_index :item, :name, unique: true
    add_index :item, :category_id
    add_index :item, :fling_effect_id
  end
end
