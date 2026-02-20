# == Schema Information
#
# Table name: item_pocket
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_item_pocket_on_name  (name) UNIQUE
#
class PokeItemPocket < ApplicationRecord
  self.table_name = "item_pocket"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
