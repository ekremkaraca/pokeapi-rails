# == Schema Information
#
# Table name: move
#
#  id                      :bigint           not null, primary key
#  accuracy                :integer
#  effect_chance           :integer
#  name                    :string           not null
#  power                   :integer
#  pp                      :integer
#  priority                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  contest_effect_id       :integer
#  contest_type_id         :integer
#  damage_class_id         :integer
#  effect_id               :integer
#  generation_id           :integer
#  super_contest_effect_id :integer
#  target_id               :integer
#  type_id                 :integer
#
# Indexes
#
#  index_move_on_contest_effect_id        (contest_effect_id)
#  index_move_on_contest_type_id          (contest_type_id)
#  index_move_on_damage_class_id          (damage_class_id)
#  index_move_on_generation_id            (generation_id)
#  index_move_on_name                     (name) UNIQUE
#  index_move_on_super_contest_effect_id  (super_contest_effect_id)
#  index_move_on_target_id                (target_id)
#  index_move_on_type_id                  (type_id)
#
class PokeMove < ApplicationRecord
  self.table_name = "move"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
