# == Schema Information
#
# Table name: pokemon_item
#
#  id         :bigint           not null, primary key
#  rarity     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :integer          not null
#  pokemon_id :integer          not null
#  version_id :integer          not null
#
# Indexes
#
#  idx_pokemon_item_on_pokemon_item_version  (pokemon_id,item_id,version_id) UNIQUE
#  index_pokemon_item_on_item_id             (item_id)
#  index_pokemon_item_on_version_id          (version_id)
#
class PokePokemonItem < ApplicationRecord
  self.table_name = "pokemon_item"
end
