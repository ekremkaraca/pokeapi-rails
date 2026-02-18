class CreateStat < ActiveRecord::Migration[8.1]
  def change
    create_table :stat do |t|
      t.string :name, null: false
      t.integer :damage_class_id
      t.boolean :is_battle_only, null: false, default: false
      t.integer :game_index

      t.timestamps
    end

    add_index :stat, :name, unique: true
    add_index :stat, :damage_class_id
    add_index :stat, :is_battle_only
    add_index :stat, :game_index
  end
end
