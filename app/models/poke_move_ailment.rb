class PokeMoveAilment < ApplicationRecord
  self.table_name = "move_ailment"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
