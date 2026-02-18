class PokeMoveMetaCategory < ApplicationRecord
  self.table_name = "move_meta_category"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
