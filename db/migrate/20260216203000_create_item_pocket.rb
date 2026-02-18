class CreateItemPocket < ActiveRecord::Migration[8.1]
  def change
    create_table :item_pocket do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :item_pocket, :name, unique: true
  end
end
