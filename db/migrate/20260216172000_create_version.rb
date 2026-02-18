class CreateVersion < ActiveRecord::Migration[8.1]
  def change
    create_table :version do |t|
      t.string :name, null: false
      t.integer :version_group_id

      t.timestamps
    end

    add_index :version, :name, unique: true
    add_index :version, :version_group_id
  end
end
