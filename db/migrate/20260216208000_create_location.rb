class CreateLocation < ActiveRecord::Migration[8.1]
  def change
    create_table :location do |t|
      t.string :name, null: false
      t.integer :region_id

      t.timestamps
    end

    add_index :location, :name, unique: true
    add_index :location, :region_id
  end
end
