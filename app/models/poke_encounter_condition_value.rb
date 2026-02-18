class PokeEncounterConditionValue < ApplicationRecord
  self.table_name = "encounter_condition_value"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
