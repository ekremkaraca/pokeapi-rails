class PokeLanguage < ApplicationRecord
  self.table_name = "language"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
