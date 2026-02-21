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

  belongs_to :damage_type,
             class_name: "PokeType",
             foreign_key: :damage_type_id,
             inverse_of: :type_efficacies_as_damage_type
  belongs_to :target_type,
             class_name: "PokeType",
             foreign_key: :target_type_id,
             inverse_of: :type_efficacies_as_target_type
end
