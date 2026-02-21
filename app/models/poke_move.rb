# == Schema Information
#
# Table name: move
#
#  id                      :bigint           not null, primary key
#  accuracy                :integer
#  effect_chance           :integer
#  name                    :string           not null
#  power                   :integer
#  pp                      :integer
#  priority                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  contest_effect_id       :integer
#  contest_type_id         :integer
#  damage_class_id         :integer
#  effect_id               :integer
#  generation_id           :integer
#  super_contest_effect_id :integer
#  target_id               :integer
#  type_id                 :integer
#
# Indexes
#
#  index_move_on_contest_effect_id        (contest_effect_id)
#  index_move_on_contest_type_id          (contest_type_id)
#  index_move_on_damage_class_id          (damage_class_id)
#  index_move_on_generation_id            (generation_id)
#  index_move_on_name                     (name) UNIQUE
#  index_move_on_super_contest_effect_id  (super_contest_effect_id)
#  index_move_on_target_id                (target_id)
#  index_move_on_type_id                  (type_id)
#
class PokeMove < ApplicationRecord
  self.table_name = "move"

  belongs_to :contest_effect,
             class_name: "PokeContestEffect",
             foreign_key: :contest_effect_id,
             inverse_of: :moves,
             optional: true
  belongs_to :contest_type,
             class_name: "PokeContestType",
             foreign_key: :contest_type_id,
             inverse_of: :moves,
             optional: true
  belongs_to :damage_class,
             class_name: "PokeMoveDamageClass",
             foreign_key: :damage_class_id,
             inverse_of: :moves,
             optional: true
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :moves,
             optional: true
  belongs_to :super_contest_effect,
             class_name: "PokeSuperContestEffect",
             foreign_key: :super_contest_effect_id,
             inverse_of: :moves,
             optional: true
  belongs_to :target,
             class_name: "PokeMoveTarget",
             foreign_key: :target_id,
             inverse_of: :moves,
             optional: true
  belongs_to :type,
             class_name: "PokeType",
             foreign_key: :type_id,
             inverse_of: :moves,
             optional: true

  has_many :move_changelogs,
           class_name: "PokeMoveChangelog",
           foreign_key: :move_id,
           inverse_of: :move,
           dependent: :restrict_with_exception
  has_many :move_effect_changelogs,
           class_name: "PokeMoveEffectChangelog",
           primary_key: :effect_id,
           foreign_key: :effect_id
  has_many :move_effect_proses,
           class_name: "PokeMoveEffectProse",
           primary_key: :effect_id,
           foreign_key: :move_effect_id
  has_many :move_names,
           class_name: "PokeMoveName",
           foreign_key: :move_id,
           inverse_of: :move,
           dependent: :restrict_with_exception
  has_many :move_flavor_texts,
           class_name: "PokeMoveFlavorText",
           foreign_key: :move_id,
           inverse_of: :move,
           dependent: :restrict_with_exception
  has_one :move_meta,
          class_name: "PokeMoveMeta",
          foreign_key: :move_id,
          inverse_of: :move,
          dependent: :destroy
  has_many :move_meta_stat_changes,
           class_name: "PokeMoveMetaStatChange",
           foreign_key: :move_id,
           inverse_of: :move,
           dependent: :destroy
  has_many :pokemon_moves,
           class_name: "PokePokemonMove",
           foreign_key: :move_id,
           inverse_of: :move,
           dependent: :restrict_with_exception
  has_many :contest_combos_as_first,
           class_name: "PokeContestCombo",
           foreign_key: :first_move_id,
           inverse_of: :first_move,
           dependent: :restrict_with_exception
  has_many :contest_combos_as_second,
           class_name: "PokeContestCombo",
           foreign_key: :second_move_id,
           inverse_of: :second_move,
           dependent: :restrict_with_exception
  has_many :super_contest_combos_as_first,
           class_name: "PokeSuperContestCombo",
           foreign_key: :first_move_id,
           inverse_of: :first_move,
           dependent: :restrict_with_exception
  has_many :super_contest_combos_as_second,
           class_name: "PokeSuperContestCombo",
           foreign_key: :second_move_id,
           inverse_of: :second_move,
           dependent: :restrict_with_exception
  has_many :machines,
           class_name: "PokeMachine",
           foreign_key: :move_id,
           inverse_of: :move,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
