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

  belongs_to :color,
             class_name: "PokePokemonColor",
             foreign_key: :color_id,
             inverse_of: :pokemon_species,
             optional: true
  belongs_to :evolution_chain,
             class_name: "PokeEvolutionChain",
             foreign_key: :evolution_chain_id,
             inverse_of: :pokemon_species,
             optional: true
  belongs_to :evolves_from_species,
             class_name: "PokePokemonSpecies",
             foreign_key: :evolves_from_species_id,
             inverse_of: :evolves_to_species,
             optional: true
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :pokemon_species,
             optional: true
  belongs_to :growth_rate,
             class_name: "PokeGrowthRate",
             foreign_key: :growth_rate_id,
             inverse_of: :pokemon_species,
             optional: true
  belongs_to :habitat,
             class_name: "PokePokemonHabitat",
             foreign_key: :habitat_id,
             inverse_of: :pokemon_species,
             optional: true
  belongs_to :shape,
             class_name: "PokePokemonShape",
             foreign_key: :shape_id,
             inverse_of: :pokemon_species,
             optional: true

  has_many :evolves_to_species,
           class_name: "PokePokemonSpecies",
           foreign_key: :evolves_from_species_id,
           inverse_of: :evolves_from_species,
           dependent: :nullify
  has_many :pokemon,
           class_name: "Pokemon",
           foreign_key: :species_id,
           inverse_of: :species,
           dependent: :nullify
  has_many :pokemon_dex_numbers,
           class_name: "PokePokemonDexNumber",
           foreign_key: :species_id,
           inverse_of: :pokemon_species,
           dependent: :restrict_with_exception
  has_many :pokemon_egg_groups,
           class_name: "PokePokemonEggGroup",
           foreign_key: :species_id,
           inverse_of: :pokemon_species,
           dependent: :restrict_with_exception
  has_many :pokemon_species_flavor_texts,
           class_name: "PokePokemonSpeciesFlavorText",
           foreign_key: :species_id,
           inverse_of: :pokemon_species,
           dependent: :restrict_with_exception
  has_many :pokemon_species_names,
           class_name: "PokePokemonSpeciesName",
           foreign_key: :pokemon_species_id,
           inverse_of: :pokemon_species,
           dependent: :restrict_with_exception
  has_many :pokemon_species_proses,
           class_name: "PokePokemonSpeciesProse",
           foreign_key: :pokemon_species_id,
           inverse_of: :pokemon_species,
           dependent: :restrict_with_exception
  has_many :pal_parks,
           class_name: "PokePalPark",
           foreign_key: :species_id,
           inverse_of: :pokemon_species,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
