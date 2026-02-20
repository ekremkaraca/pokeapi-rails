# == Schema Information
#
# Table name: move_damage_class
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_move_damage_class_on_name  (name) UNIQUE
#
class PokeMoveDamageClass < ApplicationRecord
  self.table_name = "move_damage_class"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
