class CreateEncounterCondition < ActiveRecord::Migration[8.1]
  def change
    create_table :encounter_condition do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :encounter_condition, :name, unique: true
  end
end
