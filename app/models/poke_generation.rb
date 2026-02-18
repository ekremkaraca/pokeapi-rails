class PokeGeneration < ApplicationRecord
  self.table_name = "generation"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
