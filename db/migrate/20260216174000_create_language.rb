class CreateLanguage < ActiveRecord::Migration[8.1]
  def change
    create_table :language do |t|
      t.string :name, null: false
      t.string :iso639
      t.string :iso3166
      t.boolean :official, null: false, default: false
      t.integer :sort_order

      t.timestamps
    end

    add_index :language, :name, unique: true
    add_index :language, :iso639
    add_index :language, :iso3166
    add_index :language, :official
    add_index :language, :sort_order
  end
end
