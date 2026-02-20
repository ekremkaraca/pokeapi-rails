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
end
