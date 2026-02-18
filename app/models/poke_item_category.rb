class PokeItemCategory < ApplicationRecord
  self.table_name = "item_category"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
