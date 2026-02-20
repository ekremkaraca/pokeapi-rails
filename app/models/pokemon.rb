# == Schema Information
#
# Table name: pokemon
#
#  id              :bigint           not null, primary key
#  base_experience :integer
#  height          :integer
#  is_default      :boolean
#  name            :string           not null
#  sort_order      :integer
#  weight          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  species_id      :integer
#
# Indexes
#
#  index_pokemon_on_is_default  (is_default)
#  index_pokemon_on_name        (name) UNIQUE
#  index_pokemon_on_sort_order  (sort_order)
#  index_pokemon_on_species_id  (species_id)
#
class Pokemon < ApplicationRecord
  self.table_name = "pokemon"

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :default_forms, -> { where(is_default: true) }
end
