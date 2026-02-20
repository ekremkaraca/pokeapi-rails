# == Schema Information
#
# Table name: item_attribute
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_item_attribute_on_name  (name) UNIQUE
#
class PokeItemAttribute < ApplicationRecord
  self.table_name = "item_attribute"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
