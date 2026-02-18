class PokePokemonColor < ApplicationRecord
  self.table_name = "pokemon_color"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
