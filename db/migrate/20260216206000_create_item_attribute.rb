class CreateItemAttribute < ActiveRecord::Migration[8.1]
  def change
    create_table :item_attribute do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :item_attribute, :name, unique: true
  end
end
