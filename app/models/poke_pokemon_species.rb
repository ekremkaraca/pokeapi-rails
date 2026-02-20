# == Schema Information
#
# Table name: pokemon_species
#
#  id                      :bigint           not null, primary key
#  base_happiness          :integer
#  capture_rate            :integer
#  conquest_order          :integer
#  forms_switchable        :boolean          default(FALSE), not null
#  gender_rate             :integer
#  has_gender_differences  :boolean          default(FALSE), not null
#  hatch_counter           :integer
#  is_baby                 :boolean          default(FALSE), not null
#  is_legendary            :boolean          default(FALSE), not null
#  is_mythical             :boolean          default(FALSE), not null
#  name                    :string           not null
#  sort_order              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  color_id                :integer
#  evolution_chain_id      :integer
#  evolves_from_species_id :integer
#  generation_id           :integer
#  growth_rate_id          :integer
#  habitat_id              :integer
#  shape_id                :integer
#
# Indexes
#
#  index_pokemon_species_on_color_id                 (color_id)
#  index_pokemon_species_on_conquest_order           (conquest_order)
#  index_pokemon_species_on_evolution_chain_id       (evolution_chain_id)
#  index_pokemon_species_on_evolves_from_species_id  (evolves_from_species_id)
#  index_pokemon_species_on_forms_switchable         (forms_switchable)
#  index_pokemon_species_on_generation_id            (generation_id)
#  index_pokemon_species_on_growth_rate_id           (growth_rate_id)
#  index_pokemon_species_on_habitat_id               (habitat_id)
#  index_pokemon_species_on_has_gender_differences   (has_gender_differences)
#  index_pokemon_species_on_is_baby                  (is_baby)
#  index_pokemon_species_on_is_legendary             (is_legendary)
#  index_pokemon_species_on_is_mythical              (is_mythical)
#  index_pokemon_species_on_name                     (name) UNIQUE
#  index_pokemon_species_on_shape_id                 (shape_id)
#  index_pokemon_species_on_sort_order               (sort_order)
#
class PokePokemonSpecies < ApplicationRecord
  self.table_name = "pokemon_species"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
