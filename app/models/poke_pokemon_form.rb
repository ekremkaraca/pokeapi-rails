# == Schema Information
#
# Table name: pokemon_form
#
#  id                             :bigint           not null, primary key
#  form_name                      :string
#  form_order                     :integer
#  is_battle_only                 :boolean          default(FALSE), not null
#  is_default                     :boolean          default(FALSE), not null
#  is_mega                        :boolean          default(FALSE), not null
#  name                           :string           not null
#  sort_order                     :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  introduced_in_version_group_id :integer
#  pokemon_id                     :integer
#
# Indexes
#
#  index_pokemon_form_on_form_order                      (form_order)
#  index_pokemon_form_on_introduced_in_version_group_id  (introduced_in_version_group_id)
#  index_pokemon_form_on_is_battle_only                  (is_battle_only)
#  index_pokemon_form_on_is_default                      (is_default)
#  index_pokemon_form_on_is_mega                         (is_mega)
#  index_pokemon_form_on_name                            (name) UNIQUE
#  index_pokemon_form_on_pokemon_id                      (pokemon_id)
#  index_pokemon_form_on_sort_order                      (sort_order)
#
class PokePokemonForm < ApplicationRecord
  self.table_name = "pokemon_form"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
