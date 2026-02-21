# == Schema Information
#
# Table name: type
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  damage_class_id :integer
#  generation_id   :integer
#
# Indexes
#
#  index_type_on_damage_class_id  (damage_class_id)
#  index_type_on_generation_id    (generation_id)
#  index_type_on_name             (name) UNIQUE
#
class PokeType < ApplicationRecord
  self.table_name = "type"

  belongs_to :damage_class,
             class_name: "PokeMoveDamageClass",
             foreign_key: :damage_class_id,
             inverse_of: :types,
             optional: true
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :types,
             optional: true

  has_many :pokemon_types,
           class_name: "PokePokemonType",
           foreign_key: :type_id,
           inverse_of: :type,
           dependent: :restrict_with_exception
  has_many :pokemon_type_pasts,
           class_name: "PokePokemonTypePast",
           foreign_key: :type_id,
           inverse_of: :type,
           dependent: :restrict_with_exception
  has_many :natural_gift_berries,
           class_name: "PokeBerry",
           foreign_key: :natural_gift_type_id,
           inverse_of: :natural_gift_type,
           dependent: :nullify
  has_many :type_names,
           class_name: "PokeTypeName",
           foreign_key: :type_id,
           inverse_of: :type,
           dependent: :restrict_with_exception
  has_many :moves,
           class_name: "PokeMove",
           foreign_key: :type_id,
           inverse_of: :type,
           dependent: :nullify
  has_many :move_changelogs,
           class_name: "PokeMoveChangelog",
           foreign_key: :type_id,
           inverse_of: :type,
           dependent: :nullify
  has_many :type_efficacies_as_damage_type,
           class_name: "PokeTypeEfficacy",
           foreign_key: :damage_type_id,
           inverse_of: :damage_type,
           dependent: :restrict_with_exception
  has_many :type_efficacies_as_target_type,
           class_name: "PokeTypeEfficacy",
           foreign_key: :target_type_id,
           inverse_of: :target_type,
           dependent: :restrict_with_exception
  has_many :type_efficacy_pasts_as_damage_type,
           class_name: "PokeTypeEfficacyPast",
           foreign_key: :damage_type_id,
           inverse_of: :damage_type,
           dependent: :restrict_with_exception
  has_many :type_efficacy_pasts_as_target_type,
           class_name: "PokeTypeEfficacyPast",
           foreign_key: :target_type_id,
           inverse_of: :target_type,
           dependent: :restrict_with_exception
  has_many :type_game_indices,
           class_name: "PokeTypeGameIndex",
           foreign_key: :type_id,
           inverse_of: :type,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
