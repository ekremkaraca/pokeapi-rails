class PokePokedex < ApplicationRecord
  self.table_name = "pokedex"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
