class PokeLocationArea < ApplicationRecord
  self.table_name = "location_area"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
