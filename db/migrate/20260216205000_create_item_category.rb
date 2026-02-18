class CreateItemCategory < ActiveRecord::Migration[8.1]
  def change
    create_table :item_category do |t|
      t.string :name, null: false
      t.integer :pocket_id

      t.timestamps
    end

    add_index :item_category, :name, unique: true
    add_index :item_category, :pocket_id
  end
end
