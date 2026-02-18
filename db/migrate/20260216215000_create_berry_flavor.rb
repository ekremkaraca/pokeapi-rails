class CreateBerryFlavor < ActiveRecord::Migration[8.1]
  def change
    create_table :berry_flavor do |t|
      t.string :name, null: false
      t.integer :contest_type_id

      t.timestamps
    end

    add_index :berry_flavor, :name, unique: true
    add_index :berry_flavor, :contest_type_id
  end
end
