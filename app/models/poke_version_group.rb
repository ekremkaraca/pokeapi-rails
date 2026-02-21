# == Schema Information
#
# Table name: version_group
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  sort_order    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer
#
# Indexes
#
#  index_version_group_on_generation_id  (generation_id)
#  index_version_group_on_name           (name) UNIQUE
#  index_version_group_on_sort_order     (sort_order)
#
class PokeVersionGroup < ApplicationRecord
  self.table_name = "version_group"

  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :version_groups,
             optional: true

  has_many :ability_flavor_texts,
           class_name: "PokeAbilityFlavorText",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :item_flavor_texts,
           class_name: "PokeItemFlavorText",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :move_flavor_texts,
           class_name: "PokeMoveFlavorText",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :ability_changelogs,
           class_name: "PokeAbilityChangelog",
           foreign_key: :changed_in_version_group_id,
           inverse_of: :changed_in_version_group,
           dependent: :restrict_with_exception
  has_many :move_changelogs,
           class_name: "PokeMoveChangelog",
           foreign_key: :changed_in_version_group_id,
           inverse_of: :changed_in_version_group,
           dependent: :restrict_with_exception
  has_many :move_effect_changelogs,
           class_name: "PokeMoveEffectChangelog",
           foreign_key: :changed_in_version_group_id,
           inverse_of: :changed_in_version_group,
           dependent: :restrict_with_exception
  has_many :machines,
           class_name: "PokeMachine",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :nullify
  has_many :versions,
           class_name: "PokeVersion",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :nullify
  has_many :pokemon_forms,
           class_name: "PokePokemonForm",
           foreign_key: :introduced_in_version_group_id,
           inverse_of: :introduced_in_version_group,
           dependent: :nullify
  has_many :pokemon_moves,
           class_name: "PokePokemonMove",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :encounter_slots,
           class_name: "PokeEncounterSlot",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :version_group_pokemon_move_methods,
           class_name: "PokeVersionGroupPokemonMoveMethod",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :pokedex_version_groups,
           class_name: "PokePokedexVersionGroup",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :pokedexes,
           through: :pokedex_version_groups,
           source: :pokedex
  has_many :version_group_regions,
           class_name: "PokeVersionGroupRegion",
           foreign_key: :version_group_id,
           inverse_of: :version_group,
           dependent: :restrict_with_exception
  has_many :regions,
           through: :version_group_regions,
           source: :region
  has_many :move_learn_methods,
           through: :version_group_pokemon_move_methods,
           source: :move_learn_method

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
