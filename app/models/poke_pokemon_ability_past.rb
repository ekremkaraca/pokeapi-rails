# == Schema Information
#
# Table name: pokemon_ability_past
#
#  id            :bigint           not null, primary key
#  is_hidden     :boolean          default(FALSE), not null
#  slot          :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ability_id    :integer
#  generation_id :integer          not null
#  pokemon_id    :integer          not null
#
# Indexes
#
#  idx_pokemon_ability_past_on_pokemon_generation_slot  (pokemon_id,generation_id,slot) UNIQUE
#  index_pokemon_ability_past_on_ability_id             (ability_id)
#  index_pokemon_ability_past_on_generation_id          (generation_id)
#
class PokePokemonAbilityPast < ApplicationRecord
  self.table_name = "pokemon_ability_past"

  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :pokemon_ability_pasts
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :pokemon_ability_pasts
  belongs_to :ability,
             class_name: "Ability",
             foreign_key: :ability_id,
             optional: true
end
