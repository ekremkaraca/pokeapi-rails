# == Schema Information
#
# Table name: pokemon_type_past
#
#  id            :bigint           not null, primary key
#  slot          :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer          not null
#  pokemon_id    :integer          not null
#  type_id       :integer          not null
#
# Indexes
#
#  idx_pokemon_type_past_on_pokemon_generation_slot  (pokemon_id,generation_id,slot) UNIQUE
#  index_pokemon_type_past_on_generation_id          (generation_id)
#  index_pokemon_type_past_on_type_id                (type_id)
#
class PokePokemonTypePast < ApplicationRecord
  self.table_name = "pokemon_type_past"

  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :pokemon_type_pasts
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :pokemon_type_pasts
  belongs_to :type,
             class_name: "PokeType",
             foreign_key: :type_id,
             inverse_of: :pokemon_type_pasts
end
