# == Schema Information
#
# Table name: item_flavor_text
#
#  id               :bigint           not null, primary key
#  flavor_text      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  item_id          :integer          not null
#  language_id      :integer          not null
#  version_group_id :integer          not null
#
# Indexes
#
#  idx_item_flavor_text_unique                 (item_id,version_group_id,language_id) UNIQUE
#  index_item_flavor_text_on_language_id       (language_id)
#  index_item_flavor_text_on_version_group_id  (version_group_id)
#
class PokeItemFlavorText < ApplicationRecord
  self.table_name = "item_flavor_text"

  belongs_to :item,
             class_name: "PokeItem",
             foreign_key: :item_id,
             inverse_of: :item_flavor_texts
  belongs_to :language,
             class_name: "PokeLanguage",
             foreign_key: :language_id,
             inverse_of: :item_flavor_texts
  belongs_to :version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :version_group_id,
             inverse_of: :item_flavor_texts
end
