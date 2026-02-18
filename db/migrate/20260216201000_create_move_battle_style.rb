class CreateMoveBattleStyle < ActiveRecord::Migration[8.1]
  def change
    create_table :move_battle_style do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :move_battle_style, :name, unique: true
  end
end
