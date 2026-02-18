class PokeItemAttribute < ApplicationRecord
  self.table_name = "item_attribute"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
