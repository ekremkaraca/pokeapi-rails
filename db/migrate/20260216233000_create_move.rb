class CreateMove < ActiveRecord::Migration[8.1]
  def change
    create_table :move do |t|
      t.string :name, null: false
      t.integer :generation_id
      t.integer :type_id
      t.integer :power
      t.integer :pp
      t.integer :accuracy
      t.integer :priority
      t.integer :target_id
      t.integer :damage_class_id
      t.integer :effect_id
      t.integer :effect_chance
      t.integer :contest_type_id
      t.integer :contest_effect_id
      t.integer :super_contest_effect_id

      t.timestamps
    end

    add_index :move, :name, unique: true
    add_index :move, :generation_id
    add_index :move, :type_id
    add_index :move, :target_id
    add_index :move, :damage_class_id
    add_index :move, :contest_type_id
    add_index :move, :contest_effect_id
    add_index :move, :super_contest_effect_id
  end
end
