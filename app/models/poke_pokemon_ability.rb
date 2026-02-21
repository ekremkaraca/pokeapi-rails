# == Schema Information
#
# Table name: pokemon_ability
#
#  id         :bigint           not null, primary key
#  is_hidden  :boolean          default(FALSE), not null
#  slot       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ability_id :integer          not null
#  pokemon_id :integer          not null
#
# Indexes
#
#  idx_pokemon_ability_on_pokemon_slot_ability  (pokemon_id,slot,ability_id) UNIQUE
#  index_pokemon_ability_on_ability_id          (ability_id)
#
class PokePokemonAbility < ApplicationRecord
  self.table_name = "pokemon_ability"

  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :pokemon_abilities
  belongs_to :ability,
             class_name: "Ability",
             foreign_key: :ability_id,
             inverse_of: :pokemon_abilities
end
