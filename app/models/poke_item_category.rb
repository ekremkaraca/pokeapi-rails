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

  belongs_to :pocket,
             class_name: "PokeItemPocket",
             foreign_key: :pocket_id,
             inverse_of: :item_categories,
             optional: true

  has_many :items,
           class_name: "PokeItem",
           foreign_key: :category_id,
           inverse_of: :category,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
