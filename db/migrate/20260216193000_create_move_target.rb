class CreateMoveTarget < ActiveRecord::Migration[8.1]
  def change
    create_table :move_target do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :move_target, :name, unique: true
  end
end
