# == Schema Information
#
# Table name: generation
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  main_region_id :integer
#
# Indexes
#
#  index_generation_on_main_region_id  (main_region_id)
#  index_generation_on_name            (name) UNIQUE
#
class PokeGeneration < ApplicationRecord
  self.table_name = "generation"

  belongs_to :main_region,
             class_name: "PokeRegion",
             foreign_key: :main_region_id,
             inverse_of: :main_generations,
             optional: true

  has_many :pokemon_species,
           class_name: "PokePokemonSpecies",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :nullify
  has_many :pokemon_ability_pasts,
           class_name: "PokePokemonAbilityPast",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :pokemon_stat_pasts,
           class_name: "PokePokemonStatPast",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :pokemon_type_pasts,
           class_name: "PokePokemonTypePast",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :item_game_indices,
           class_name: "PokeItemGameIndex",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :location_game_indices,
           class_name: "PokeLocationGameIndex",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :generation_names,
           class_name: "PokeGenerationName",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :version_groups,
           class_name: "PokeVersionGroup",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :nullify
  has_many :moves,
           class_name: "PokeMove",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :nullify
  has_many :abilities,
           class_name: "Ability",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :nullify
  has_many :types,
           class_name: "PokeType",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :nullify
  has_many :type_efficacy_pasts,
           class_name: "PokeTypeEfficacyPast",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception
  has_many :type_game_indices,
           class_name: "PokeTypeGameIndex",
           foreign_key: :generation_id,
           inverse_of: :generation,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
