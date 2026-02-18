class PokeEncounterMethod < ApplicationRecord
  self.table_name = "encounter_method"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
