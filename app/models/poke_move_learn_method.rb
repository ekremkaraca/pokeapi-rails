# == Schema Information
#
# Table name: move_learn_method
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_learn_method_on_name  (name) UNIQUE
#
class PokeMoveLearnMethod < ApplicationRecord
  self.table_name = "move_learn_method"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
