class PokeBerryFirmness < ApplicationRecord
  self.table_name = "berry_firmness"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
