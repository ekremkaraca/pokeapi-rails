class PokeMoveLearnMethod < ApplicationRecord
  self.table_name = "move_learn_method"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
