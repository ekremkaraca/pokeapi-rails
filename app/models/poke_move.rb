class PokeMove < ApplicationRecord
  self.table_name = "move"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
