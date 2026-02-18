class CreateMoveDamageClass < ActiveRecord::Migration[8.1]
  def change
    create_table :move_damage_class do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :move_damage_class, :name, unique: true
  end
end
