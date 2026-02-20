# == Schema Information
#
# Table name: item
#
#  id              :bigint           not null, primary key
#  cost            :integer
#  fling_power     :integer
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :integer
#  fling_effect_id :integer
#
# Indexes
#
#  index_item_on_category_id      (category_id)
#  index_item_on_fling_effect_id  (fling_effect_id)
#  index_item_on_name             (name)
#
class PokeItem < ApplicationRecord
  self.table_name = "item"

  validates :name, presence: true
end
