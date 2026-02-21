# == Schema Information
#
# Table name: item_fling_effect
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_item_fling_effect_on_name  (name) UNIQUE
#
class PokeItemFlingEffect < ApplicationRecord
  self.table_name = "item_fling_effect"

  has_many :items,
           class_name: "PokeItem",
           foreign_key: :fling_effect_id,
           inverse_of: :fling_effect,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
