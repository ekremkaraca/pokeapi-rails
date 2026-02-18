class PokeContestType < ApplicationRecord
  self.table_name = "contest_type"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
