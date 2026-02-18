class CreateEncounterMethod < ActiveRecord::Migration[8.1]
  def change
    create_table :encounter_method do |t|
      t.string :name, null: false
      t.integer :sort_order

      t.timestamps
    end

    add_index :encounter_method, :name, unique: true
    add_index :encounter_method, :sort_order
  end
end
