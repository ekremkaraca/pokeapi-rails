# == Schema Information
#
# Table name: type
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  damage_class_id :integer
#  generation_id   :integer
#
# Indexes
#
#  index_type_on_damage_class_id  (damage_class_id)
#  index_type_on_generation_id    (generation_id)
#  index_type_on_name             (name) UNIQUE
#
class PokeType < ApplicationRecord
  self.table_name = "type"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
