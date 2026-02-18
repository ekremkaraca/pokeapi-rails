class CreatePokemonForm < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_form do |t|
      t.string :name, null: false
      t.string :form_name
      t.integer :pokemon_id
      t.integer :introduced_in_version_group_id
      t.boolean :is_default, null: false, default: false
      t.boolean :is_battle_only, null: false, default: false
      t.boolean :is_mega, null: false, default: false
      t.integer :form_order
      t.integer :sort_order

      t.timestamps
    end

    add_index :pokemon_form, :name, unique: true
    add_index :pokemon_form, :pokemon_id
    add_index :pokemon_form, :introduced_in_version_group_id
    add_index :pokemon_form, :is_default
    add_index :pokemon_form, :is_battle_only
    add_index :pokemon_form, :is_mega
    add_index :pokemon_form, :form_order
    add_index :pokemon_form, :sort_order
  end
end
