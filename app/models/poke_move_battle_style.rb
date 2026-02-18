class PokeMoveBattleStyle < ApplicationRecord
  self.table_name = "move_battle_style"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
