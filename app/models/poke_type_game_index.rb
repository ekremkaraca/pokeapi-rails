# == Schema Information
#
# Table name: type_game_index
#
#  id            :bigint           not null, primary key
#  game_index    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer          not null
#  type_id       :integer          not null
#
# Indexes
#
#  index_type_game_index_on_generation_id              (generation_id)
#  index_type_game_index_on_type_id_and_generation_id  (type_id,generation_id) UNIQUE
#
class PokeTypeGameIndex < ApplicationRecord
  self.table_name = "type_game_index"
end
