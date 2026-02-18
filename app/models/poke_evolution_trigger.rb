class PokeEvolutionTrigger < ApplicationRecord
  self.table_name = "evolution_trigger"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
