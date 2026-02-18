class PokeBerryFlavor < ApplicationRecord
  self.table_name = "berry_flavor"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
