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

  belongs_to :species,
             class_name: "PokePokemonSpecies",
             foreign_key: :species_id,
             inverse_of: :pokemon,
             optional: true

  has_many :pokemon_abilities,
           class_name: "PokePokemonAbility",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_ability_pasts,
           class_name: "PokePokemonAbilityPast",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_forms,
           class_name: "PokePokemonForm",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :nullify
  has_many :pokemon_game_indices,
           class_name: "PokePokemonGameIndex",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_moves,
           class_name: "PokePokemonMove",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_stats,
           class_name: "PokePokemonStat",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_stat_pasts,
           class_name: "PokePokemonStatPast",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_types,
           class_name: "PokePokemonType",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :pokemon_type_pasts,
           class_name: "PokePokemonTypePast",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :encounters,
           class_name: "PokeEncounter",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :restrict_with_exception
  has_many :pokemon_items,
           class_name: "PokePokemonItem",
           foreign_key: :pokemon_id,
           inverse_of: :pokemon,
           dependent: :destroy
  has_many :abilities, through: :pokemon_abilities

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :default_forms, -> { where(is_default: true) }
end
