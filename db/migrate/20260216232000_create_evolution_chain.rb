class CreateEvolutionChain < ActiveRecord::Migration[8.1]
  def change
    create_table :evolution_chain do |t|
      t.integer :baby_trigger_item_id

      t.timestamps
    end

    add_index :evolution_chain, :baby_trigger_item_id
  end
end
