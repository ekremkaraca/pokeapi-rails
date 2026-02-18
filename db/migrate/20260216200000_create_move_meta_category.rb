class CreateMoveMetaCategory < ActiveRecord::Migration[8.1]
  def change
    create_table :move_meta_category do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :move_meta_category, :name, unique: true
  end
end
