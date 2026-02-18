class PokeType < ApplicationRecord
  self.table_name = "type"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
