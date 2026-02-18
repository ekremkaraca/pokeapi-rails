class PokePokemonForm < ApplicationRecord
  self.table_name = "pokemon_form"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
