class PokeMoveTarget < ApplicationRecord
  self.table_name = "move_target"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
