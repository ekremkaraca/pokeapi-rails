# == Schema Information
#
# Table name: item_flag_map
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  item_flag_id :integer          not null
#  item_id      :integer          not null
#
# Indexes
#
#  index_item_flag_map_on_item_flag_id              (item_flag_id)
#  index_item_flag_map_on_item_id_and_item_flag_id  (item_id,item_flag_id) UNIQUE
#
class PokeItemFlagMap < ApplicationRecord
  self.table_name = "item_flag_map"

  belongs_to :item,
             class_name: "PokeItem",
             foreign_key: :item_id,
             inverse_of: :item_flag_maps
  belongs_to :item_attribute,
             class_name: "PokeItemAttribute",
             foreign_key: :item_flag_id,
             inverse_of: :item_flag_maps
end
