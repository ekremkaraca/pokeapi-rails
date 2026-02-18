class PokeItemPocket < ApplicationRecord
  self.table_name = "item_pocket"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
