# == Schema Information
#
# Table name: version_group_pokemon_move_method
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  pokemon_move_method_id :integer          not null
#  version_group_id       :integer          not null
#
# Indexes
#
#  idx_on_pokemon_move_method_id_f7fde217e7  (pokemon_move_method_id)
#  idx_vg_pokemon_move_method_unique         (version_group_id,pokemon_move_method_id) UNIQUE
#
class PokeVersionGroupPokemonMoveMethod < ApplicationRecord
  self.table_name = "version_group_pokemon_move_method"
end
