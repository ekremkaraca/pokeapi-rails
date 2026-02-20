# == Schema Information
#
# Table name: encounter_condition
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_encounter_condition_on_name  (name) UNIQUE
#
class PokeEncounterCondition < ApplicationRecord
  self.table_name = "encounter_condition"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
