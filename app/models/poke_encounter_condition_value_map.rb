# == Schema Information
#
# Table name: encounter_condition_value_map
#
#  id                           :bigint           not null, primary key
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  encounter_condition_value_id :integer          not null
#  encounter_id                 :integer          not null
#
# Indexes
#
#  idx_encounter_condition_value_map_unique        (encounter_id,encounter_condition_value_id) UNIQUE
#  idx_on_encounter_condition_value_id_4ec3d9ce2c  (encounter_condition_value_id)
#
class PokeEncounterConditionValueMap < ApplicationRecord
  self.table_name = "encounter_condition_value_map"
end
