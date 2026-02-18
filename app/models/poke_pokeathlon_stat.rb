class PokePokeathlonStat < ApplicationRecord
  self.table_name = "pokeathlon_stat"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
