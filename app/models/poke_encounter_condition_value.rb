# == Schema Information
#
# Table name: encounter_condition_value
#
#  id                     :bigint           not null, primary key
#  is_default             :boolean          default(FALSE), not null
#  name                   :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encounter_condition_id :integer
#
# Indexes
#
#  index_encounter_condition_value_on_encounter_condition_id  (encounter_condition_id)
#  index_encounter_condition_value_on_is_default              (is_default)
#  index_encounter_condition_value_on_name                    (name) UNIQUE
#
class PokeEncounterConditionValue < ApplicationRecord
  self.table_name = "encounter_condition_value"

  belongs_to :encounter_condition,
             class_name: "PokeEncounterCondition",
             foreign_key: :encounter_condition_id,
             inverse_of: :encounter_condition_values,
             optional: true
  has_many :encounter_condition_value_maps,
           class_name: "PokeEncounterConditionValueMap",
           foreign_key: :encounter_condition_value_id,
           inverse_of: :encounter_condition_value,
           dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
