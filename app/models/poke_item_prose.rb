# == Schema Information
#
# Table name: item_prose
#
#  id                :bigint           not null, primary key
#  effect            :text
#  short_effect      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  item_id           :integer          not null
#  local_language_id :integer          not null
#
# Indexes
#
#  index_item_prose_on_item_id_and_local_language_id  (item_id,local_language_id) UNIQUE
#  index_item_prose_on_local_language_id              (local_language_id)
#
class PokeItemProse < ApplicationRecord
  self.table_name = "item_prose"

  belongs_to :item,
             class_name: "PokeItem",
             foreign_key: :item_id,
             inverse_of: :item_proses
  belongs_to :local_language,
             class_name: "PokeLanguage",
             foreign_key: :local_language_id,
             inverse_of: :item_proses
end
