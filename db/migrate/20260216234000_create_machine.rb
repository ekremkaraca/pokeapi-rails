class CreateMachine < ActiveRecord::Migration[8.1]
  def change
    create_table :machine do |t|
      t.integer :machine_number
      t.integer :version_group_id
      t.integer :item_id
      t.integer :move_id

      t.timestamps
    end

    add_index :machine, :machine_number
    add_index :machine, :version_group_id
    add_index :machine, :item_id
    add_index :machine, :move_id
    add_index :machine, [ :machine_number, :version_group_id ], unique: true
  end
end
