class CreateEggGroup < ActiveRecord::Migration[8.1]
  def change
    create_table :egg_group do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :egg_group, :name, unique: true
  end
end
