class CreateContestType < ActiveRecord::Migration[8.1]
  def change
    create_table :contest_type do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :contest_type, :name, unique: true
  end
end
