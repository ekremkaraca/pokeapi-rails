class CreateMoveAilment < ActiveRecord::Migration[8.1]
  def change
    create_table :move_ailment, id: false do |t|
      t.integer :id, null: false, primary_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :move_ailment, :name, unique: true
  end
end
