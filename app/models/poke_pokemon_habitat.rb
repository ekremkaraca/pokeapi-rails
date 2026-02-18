class PokePokemonHabitat < ApplicationRecord
  self.table_name = "pokemon_habitat"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
