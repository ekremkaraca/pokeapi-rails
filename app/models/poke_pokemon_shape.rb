class PokePokemonShape < ApplicationRecord
  self.table_name = "pokemon_shape"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
