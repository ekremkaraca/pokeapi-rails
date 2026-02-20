# == Schema Information
#
# Table name: pokemon_type
#
#  id         :bigint           not null, primary key
#  slot       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pokemon_id :integer          not null
#  type_id    :integer          not null
#
# Indexes
#
#  index_pokemon_type_on_pokemon_id_and_slot  (pokemon_id,slot) UNIQUE
#  index_pokemon_type_on_type_id              (type_id)
#
class PokePokemonType < ApplicationRecord
  self.table_name = "pokemon_type"
end
