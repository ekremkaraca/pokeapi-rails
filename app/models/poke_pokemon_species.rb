class PokePokemonSpecies < ApplicationRecord
  self.table_name = "pokemon_species"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
