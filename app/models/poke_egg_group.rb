class PokeEggGroup < ApplicationRecord
  self.table_name = "egg_group"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
