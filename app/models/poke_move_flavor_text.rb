# == Schema Information
#
# Table name: move_flavor_text
#
#  id               :bigint           not null, primary key
#  flavor_text      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  language_id      :integer          not null
#  move_id          :integer          not null
#  version_group_id :integer          not null
#
# Indexes
#
#  idx_move_flavor_text_lookup                 (move_id,version_group_id,language_id)
#  index_move_flavor_text_on_language_id       (language_id)
#  index_move_flavor_text_on_move_id           (move_id)
#  index_move_flavor_text_on_version_group_id  (version_group_id)
#
class PokeMoveFlavorText < ApplicationRecord
  self.table_name = "move_flavor_text"
end
