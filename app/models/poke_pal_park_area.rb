class PokePalParkArea < ApplicationRecord
  self.table_name = "pal_park_area"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
