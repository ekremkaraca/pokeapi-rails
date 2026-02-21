# == Schema Information
#
# Table name: item_game_index
#
#  id            :bigint           not null, primary key
#  game_index    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer          not null
#  item_id       :integer          not null
#
# Indexes
#
#  index_item_game_index_on_generation_id              (generation_id)
#  index_item_game_index_on_item_id_and_generation_id  (item_id,generation_id) UNIQUE
#
class PokeItemGameIndex < ApplicationRecord
  self.table_name = "item_game_index"

  belongs_to :item,
             class_name: "PokeItem",
             foreign_key: :item_id,
             inverse_of: :item_game_indices
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :item_game_indices
end
