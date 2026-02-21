# == Schema Information
#
# Table name: pokemon_species_name
#
#  id                 :bigint           not null, primary key
#  genus              :string
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  local_language_id  :integer          not null
#  pokemon_species_id :integer          not null
#
# Indexes
#
#  idx_pokemon_species_name_unique                  (pokemon_species_id,local_language_id) UNIQUE
#  index_pokemon_species_name_on_local_language_id  (local_language_id)
#
class PokePokemonSpeciesName < ApplicationRecord
  self.table_name = "pokemon_species_name"

  belongs_to :pokemon_species,
             class_name: "PokePokemonSpecies",
             foreign_key: :pokemon_species_id,
             inverse_of: :pokemon_species_names,
             optional: true
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :pokemon_species_names,
             optional: true
end
