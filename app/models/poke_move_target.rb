# == Schema Information
#
# Table name: move_target
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_target_on_name  (name) UNIQUE
#
class PokeMoveTarget < ApplicationRecord
  self.table_name = "move_target"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
