class Pokemon < ApplicationRecord
  self.table_name = "pokemon"

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :default_forms, -> { where(is_default: true) }
end
