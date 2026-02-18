class PokeBerry < ApplicationRecord
  self.table_name = "berry"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
