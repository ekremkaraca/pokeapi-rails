class CreateGeneration < ActiveRecord::Migration[8.1]
  def change
    create_table :generation do |t|
      t.string :name, null: false
      t.integer :main_region_id

      t.timestamps
    end

    add_index :generation, :name, unique: true
    add_index :generation, :main_region_id
  end
end
