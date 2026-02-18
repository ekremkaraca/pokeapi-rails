class PokeStat < ApplicationRecord
  self.table_name = "stat"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
