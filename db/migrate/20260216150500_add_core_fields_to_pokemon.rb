class AddCoreFieldsToPokemon < ActiveRecord::Migration[8.1]
  def change
    add_column :pokemon, :species_id, :integer
    add_column :pokemon, :height, :integer
    add_column :pokemon, :weight, :integer
    add_column :pokemon, :base_experience, :integer
    add_column :pokemon, :sort_order, :integer
    add_column :pokemon, :is_default, :boolean

    add_index :pokemon, :species_id
    add_index :pokemon, :sort_order
    add_index :pokemon, :is_default
  end
end
