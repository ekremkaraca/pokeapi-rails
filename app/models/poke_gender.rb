class PokeGender < ApplicationRecord
  self.table_name = "gender"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
