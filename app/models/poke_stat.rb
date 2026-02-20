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

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
