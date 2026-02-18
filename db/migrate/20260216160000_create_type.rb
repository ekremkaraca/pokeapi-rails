class CreateType < ActiveRecord::Migration[8.1]
  def change
    create_table :type do |t|
      t.string :name, null: false
      t.integer :generation_id
      t.integer :damage_class_id

      t.timestamps
    end

    add_index :type, :name, unique: true
    add_index :type, :generation_id
    add_index :type, :damage_class_id
  end
end
