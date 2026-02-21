# == Schema Information
#
# Table name: move_meta_stat_change
#
#  id         :bigint           not null, primary key
#  change     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  move_id    :integer          not null
#  stat_id    :integer          not null
#
# Indexes
#
#  idx_move_meta_stat_change_unique        (move_id,stat_id,change) UNIQUE
#  index_move_meta_stat_change_on_stat_id  (stat_id)
#
class PokeMoveMetaStatChange < ApplicationRecord
  self.table_name = "move_meta_stat_change"

  belongs_to :move,
             class_name: "PokeMove",
             foreign_key: :move_id,
             inverse_of: :move_meta_stat_changes
  belongs_to :stat,
             class_name: "PokeStat",
             foreign_key: :stat_id,
             inverse_of: :move_meta_stat_changes
end
