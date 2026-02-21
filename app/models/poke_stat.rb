# == Schema Information
#
# Table name: stat
#
#  id              :bigint           not null, primary key
#  game_index      :integer
#  is_battle_only  :boolean          default(FALSE), not null
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  damage_class_id :integer
#
# Indexes
#
#  index_stat_on_damage_class_id  (damage_class_id)
#  index_stat_on_game_index       (game_index)
#  index_stat_on_is_battle_only   (is_battle_only)
#  index_stat_on_name             (name) UNIQUE
#
class PokeStat < ApplicationRecord
  self.table_name = "stat"

  belongs_to :damage_class,
             class_name: "PokeMoveDamageClass",
             foreign_key: :damage_class_id,
             inverse_of: :stats,
             optional: true

  has_many :pokemon_stats,
           class_name: "PokePokemonStat",
           foreign_key: :stat_id,
           inverse_of: :stat,
           dependent: :restrict_with_exception
  has_many :pokemon_stat_pasts,
           class_name: "PokePokemonStatPast",
           foreign_key: :stat_id,
           inverse_of: :stat,
           dependent: :restrict_with_exception
  has_many :move_meta_stat_changes,
           class_name: "PokeMoveMetaStatChange",
           foreign_key: :stat_id,
           inverse_of: :stat,
           dependent: :restrict_with_exception
  has_many :characteristics,
           class_name: "PokeCharacteristic",
           foreign_key: :stat_id,
           inverse_of: :stat,
           dependent: :nullify
  has_many :natures_with_increased_stat,
           class_name: "PokeNature",
           foreign_key: :increased_stat_id,
           inverse_of: :increased_stat,
           dependent: :nullify
  has_many :natures_with_decreased_stat,
           class_name: "PokeNature",
           foreign_key: :decreased_stat_id,
           inverse_of: :decreased_stat,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
