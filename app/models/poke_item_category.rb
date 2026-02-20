# == Schema Information
#
# Table name: item_category
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pocket_id  :integer
#
# Indexes
#
#  index_item_category_on_name       (name) UNIQUE
#  index_item_category_on_pocket_id  (pocket_id)
#
class PokeItemCategory < ApplicationRecord
  self.table_name = "item_category"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
