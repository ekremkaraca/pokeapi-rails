class CreateBerryFirmness < ActiveRecord::Migration[8.1]
  def change
    create_table :berry_firmness do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :berry_firmness, :name, unique: true
  end
end
