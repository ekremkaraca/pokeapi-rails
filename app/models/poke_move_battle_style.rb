# == Schema Information
#
# Table name: move_battle_style
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_battle_style_on_name  (name) UNIQUE
#
class PokeMoveBattleStyle < ApplicationRecord
  self.table_name = "move_battle_style"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
