class CreateAbility < ActiveRecord::Migration[8.1]
  def change
    create_table :ability do |t|
      t.string :name, null: false
      t.integer :generation_id
      t.boolean :is_main_series, null: false, default: true

      t.timestamps
    end

    add_index :ability, :name, unique: true
    add_index :ability, :generation_id
    add_index :ability, :is_main_series
  end
end
