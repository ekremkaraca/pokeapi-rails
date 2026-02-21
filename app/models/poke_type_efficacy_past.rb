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

  belongs_to :damage_type,
             class_name: "PokeType",
             foreign_key: :damage_type_id,
             inverse_of: :type_efficacy_pasts_as_damage_type
  belongs_to :target_type,
             class_name: "PokeType",
             foreign_key: :target_type_id,
             inverse_of: :type_efficacy_pasts_as_target_type
  belongs_to :generation,
             class_name: "PokeGeneration",
             foreign_key: :generation_id,
             inverse_of: :type_efficacy_pasts
end
