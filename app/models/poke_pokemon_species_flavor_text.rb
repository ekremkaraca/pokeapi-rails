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
end
