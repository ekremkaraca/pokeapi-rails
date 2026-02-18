class CreateGrowthRate < ActiveRecord::Migration[8.1]
  def change
    create_table :growth_rate do |t|
      t.string :name, null: false
      t.string :formula

      t.timestamps
    end

    add_index :growth_rate, :name, unique: true
  end
end
