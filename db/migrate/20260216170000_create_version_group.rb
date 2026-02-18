class CreateVersionGroup < ActiveRecord::Migration[8.1]
  def change
    create_table :version_group do |t|
      t.string :name, null: false
      t.integer :generation_id
      t.integer :sort_order

      t.timestamps
    end

    add_index :version_group, :name, unique: true
    add_index :version_group, :generation_id
    add_index :version_group, :sort_order
  end
end
