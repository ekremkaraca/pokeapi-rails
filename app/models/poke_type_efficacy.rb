# == Schema Information
#
# Table name: type_efficacy
#
#  id             :bigint           not null, primary key
#  damage_factor  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  damage_type_id :integer          not null
#  target_type_id :integer          not null
#
# Indexes
#
#  index_type_efficacy_on_damage_type_id_and_target_type_id  (damage_type_id,target_type_id) UNIQUE
#  index_type_efficacy_on_target_type_id                     (target_type_id)
#
class PokeTypeEfficacy < ApplicationRecord
  self.table_name = "type_efficacy"
end
