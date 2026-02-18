class CreateEncounterConditionValue < ActiveRecord::Migration[8.1]
  def change
    create_table :encounter_condition_value do |t|
      t.string :name, null: false
      t.integer :encounter_condition_id
      t.boolean :is_default, null: false, default: false

      t.timestamps
    end

    add_index :encounter_condition_value, :name, unique: true
    add_index :encounter_condition_value, :encounter_condition_id
    add_index :encounter_condition_value, :is_default
  end
end
