# == Schema Information
#
# Table name: pokemon_egg_group
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  egg_group_id :integer          not null
#  species_id   :integer          not null
#
# Indexes
#
#  index_pokemon_egg_group_on_egg_group_id                 (egg_group_id)
#  index_pokemon_egg_group_on_species_id_and_egg_group_id  (species_id,egg_group_id) UNIQUE
#
class PokePokemonEggGroup < ApplicationRecord
  self.table_name = "pokemon_egg_group"
end
