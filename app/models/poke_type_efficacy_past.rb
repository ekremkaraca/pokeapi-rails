# == Schema Information
#
# Table name: type_efficacy_past
#
#  id             :bigint           not null, primary key
#  damage_factor  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  damage_type_id :integer          not null
#  generation_id  :integer          not null
#  target_type_id :integer          not null
#
# Indexes
#
#  idx_type_efficacy_past_unique               (damage_type_id,target_type_id,generation_id) UNIQUE
#  index_type_efficacy_past_on_generation_id   (generation_id)
#  index_type_efficacy_past_on_target_type_id  (target_type_id)
#
class PokeTypeEfficacyPast < ApplicationRecord
  self.table_name = "type_efficacy_past"
end
