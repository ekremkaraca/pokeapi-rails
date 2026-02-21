# == Schema Information
#
# Table name: pokemon_species_prose
#
#  id                 :bigint           not null, primary key
#  form_description   :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  local_language_id  :integer          not null
#  pokemon_species_id :integer          not null
#
# Indexes
#
#  idx_pokemon_species_prose_unique                  (pokemon_species_id,local_language_id) UNIQUE
#  index_pokemon_species_prose_on_local_language_id  (local_language_id)
#
class PokePokemonSpeciesProse < ApplicationRecord
  self.table_name = "pokemon_species_prose"

  belongs_to :pokemon_species,
             class_name: "PokePokemonSpecies",
             foreign_key: :pokemon_species_id,
             inverse_of: :pokemon_species_proses,
             optional: true
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :pokemon_species_proses,
             optional: true
end
