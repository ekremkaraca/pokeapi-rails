# == Schema Information
#
# Table name: location_game_index
#
#  id            :bigint           not null, primary key
#  game_index    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer          not null
#  location_id   :integer          not null
#
# Indexes
#
#  idx_location_game_index_unique              (location_id,generation_id,game_index) UNIQUE
#  index_location_game_index_on_generation_id  (generation_id)
#
class PokeLocationGameIndex < ApplicationRecord
  self.table_name = "location_game_index"

  belongs_to :location,
             class_name: "PokeLocation",
             foreign_key: :location_id,
             inverse_of: :location_game_indices,
             optional: true
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :location_game_indices,
             optional: true
end
