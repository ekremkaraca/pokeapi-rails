# == Schema Information
#
# Table name: pokemon_dex_number
#
#  id             :bigint           not null, primary key
#  pokedex_number :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  pokedex_id     :integer          not null
#  species_id     :integer          not null
#
# Indexes
#
#  index_pokemon_dex_number_on_pokedex_id                 (pokedex_id)
#  index_pokemon_dex_number_on_species_id_and_pokedex_id  (species_id,pokedex_id) UNIQUE
#
class PokePokemonDexNumber < ApplicationRecord
  self.table_name = "pokemon_dex_number"

  belongs_to :pokemon_species,
             class_name: "PokePokemonSpecies",
             foreign_key: :species_id,
             inverse_of: :pokemon_dex_numbers,
             optional: true
  belongs_to :pokedex,
             class_name: "PokePokedex",
             foreign_key: :pokedex_id,
             inverse_of: :pokemon_dex_numbers,
             optional: true
end
