class Ability < ApplicationRecord
  self.table_name = "ability"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
