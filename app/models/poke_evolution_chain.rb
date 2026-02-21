# == Schema Information
#
# Table name: evolution_chain
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  baby_trigger_item_id :integer
#
# Indexes
#
#  index_evolution_chain_on_baby_trigger_item_id  (baby_trigger_item_id)
#
class PokeEvolutionChain < ApplicationRecord
  self.table_name = "evolution_chain"

  belongs_to :baby_trigger_item,
             class_name: "PokeItem",
             foreign_key: :baby_trigger_item_id,
             inverse_of: :baby_triggered_evolution_chains,
             optional: true

  has_many :pokemon_species,
           class_name: "PokePokemonSpecies",
           foreign_key: :evolution_chain_id,
           inverse_of: :evolution_chain,
           dependent: :nullify
end
