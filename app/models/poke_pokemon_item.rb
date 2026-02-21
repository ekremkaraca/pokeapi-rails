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

  belongs_to :item,
             class_name: "PokeItem",
             foreign_key: :item_id,
             inverse_of: :pokemon_items
  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :pokemon_items
  belongs_to :version,
             class_name: "PokeVersion",
             foreign_key: :version_id,
             inverse_of: :pokemon_items
end
