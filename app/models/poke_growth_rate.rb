class PokeGrowthRate < ApplicationRecord
  self.table_name = "growth_rate"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
