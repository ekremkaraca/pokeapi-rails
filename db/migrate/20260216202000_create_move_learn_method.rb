class CreateMoveLearnMethod < ActiveRecord::Migration[8.1]
  def change
    create_table :move_learn_method do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :move_learn_method, :name, unique: true
  end
end
