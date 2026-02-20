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

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
