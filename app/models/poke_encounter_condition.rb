class PokeEncounterCondition < ApplicationRecord
  self.table_name = "encounter_condition"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
