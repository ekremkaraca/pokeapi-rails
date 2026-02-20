# == Schema Information
#
# Table name: pokemon_game_index
#
#  id         :bigint           not null, primary key
#  game_index :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pokemon_id :integer          not null
#  version_id :integer          not null
#
# Indexes
#
#  index_pokemon_game_index_on_pokemon_id_and_version_id  (pokemon_id,version_id) UNIQUE
#  index_pokemon_game_index_on_version_id                 (version_id)
#
class PokePokemonGameIndex < ApplicationRecord
  self.table_name = "pokemon_game_index"
end
