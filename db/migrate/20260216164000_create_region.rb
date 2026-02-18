class CreateRegion < ActiveRecord::Migration[8.1]
  def change
    create_table :region do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :region, :name, unique: true
  end
end
