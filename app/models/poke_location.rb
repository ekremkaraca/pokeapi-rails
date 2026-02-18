class PokeLocation < ApplicationRecord
  self.table_name = "location"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
