class PokeVersion < ApplicationRecord
  self.table_name = "version"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
