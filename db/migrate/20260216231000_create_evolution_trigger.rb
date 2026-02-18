class CreateEvolutionTrigger < ActiveRecord::Migration[8.1]
  def change
    create_table :evolution_trigger do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :evolution_trigger, :name, unique: true
  end
end
