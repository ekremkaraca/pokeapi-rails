# == Schema Information
#
# Table name: move_meta
#
#  id               :bigint           not null, primary key
#  ailment_chance   :integer
#  crit_rate        :integer
#  drain            :integer
#  flinch_chance    :integer
#  healing          :integer
#  max_hits         :integer
#  max_turns        :integer
#  min_hits         :integer
#  min_turns        :integer
#  stat_chance      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  meta_ailment_id  :integer
#  meta_category_id :integer
#  move_id          :integer          not null
#
# Indexes
#
#  index_move_meta_on_meta_ailment_id   (meta_ailment_id)
#  index_move_meta_on_meta_category_id  (meta_category_id)
#  index_move_meta_on_move_id           (move_id) UNIQUE
#
class PokeMoveMeta < ApplicationRecord
  self.table_name = "move_meta"
end
