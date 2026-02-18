class PokeMoveDamageClass < ApplicationRecord
  self.table_name = "move_damage_class"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
