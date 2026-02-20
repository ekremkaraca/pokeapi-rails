# == Schema Information
#
# Table name: pokemon_move
#
#  id                     :bigint           not null, primary key
#  level                  :integer          not null
#  mastery                :integer
#  sort_order             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  move_id                :integer          not null
#  pokemon_id             :integer          not null
#  pokemon_move_method_id :integer          not null
#  version_group_id       :integer          not null
#
# Indexes
#
#  idx_pokemon_move_uniqueness                   (pokemon_id,move_id,version_group_id,pokemon_move_method_id,level) UNIQUE
#  index_pokemon_move_on_move_id                 (move_id)
#  index_pokemon_move_on_pokemon_move_method_id  (pokemon_move_method_id)
#  index_pokemon_move_on_version_group_id        (version_group_id)
#
class PokePokemonMove < ApplicationRecord
  self.table_name = "pokemon_move"
end
