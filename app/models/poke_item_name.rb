# == Schema Information
#
# Table name: item_name
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  item_id           :integer          not null
#  local_language_id :integer          not null
#
# Indexes
#
#  index_item_name_on_item_id_and_local_language_id  (item_id,local_language_id) UNIQUE
#  index_item_name_on_local_language_id              (local_language_id)
#
class PokeItemName < ApplicationRecord
  self.table_name = "item_name"
end
