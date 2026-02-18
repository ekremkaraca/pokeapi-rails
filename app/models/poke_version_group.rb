class PokeVersionGroup < ApplicationRecord
  self.table_name = "version_group"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
