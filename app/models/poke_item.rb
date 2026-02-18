class PokeItem < ApplicationRecord
  self.table_name = "item"

  validates :name, presence: true
end
