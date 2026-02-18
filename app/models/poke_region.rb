class PokeRegion < ApplicationRecord
  self.table_name = "region"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
