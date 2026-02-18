class CreateItemFlingEffect < ActiveRecord::Migration[8.1]
  def change
    create_table :item_fling_effect do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :item_fling_effect, :name, unique: true
  end
end
