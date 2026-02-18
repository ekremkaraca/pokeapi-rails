class PokeNature < ApplicationRecord
  self.table_name = "nature"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
