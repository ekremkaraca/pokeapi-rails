# == Schema Information
#
# Table name: pokemon_species_flavor_text
#
#  id          :bigint           not null, primary key
#  flavor_text :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer          not null
#  species_id  :integer          not null
#  version_id  :integer          not null
#
# Indexes
#
#  idx_pokemon_species_flavor_text_unique            (species_id,version_id,language_id) UNIQUE
#  index_pokemon_species_flavor_text_on_language_id  (language_id)
#  index_pokemon_species_flavor_text_on_version_id   (version_id)
#
class PokePokemonSpeciesFlavorText < ApplicationRecord
  self.table_name = "pokemon_species_flavor_text"

  belongs_to :pokemon_species,
             class_name: "PokePokemonSpecies",
             foreign_key: :species_id,
             inverse_of: :pokemon_species_flavor_texts,
             optional: true
  belongs_to :version,
             class_name: "PokeVersion",
             foreign_key: :version_id,
             inverse_of: :pokemon_species_flavor_texts,
             optional: true
  belongs_to :language,
             class_name: "PokeLanguage",
             foreign_key: :language_id,
             inverse_of: :pokemon_species_flavor_texts,
             optional: true
end
