class PokeItemFlingEffect < ApplicationRecord
  self.table_name = "item_fling_effect"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
