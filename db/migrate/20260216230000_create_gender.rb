class CreateGender < ActiveRecord::Migration[8.1]
  def change
    create_table :gender do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :gender, :name, unique: true
  end
end
