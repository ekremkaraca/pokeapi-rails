# == Schema Information
#
# Table name: encounter_method
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  sort_order :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_encounter_method_on_name        (name) UNIQUE
#  index_encounter_method_on_sort_order  (sort_order)
#
class PokeEncounterMethod < ApplicationRecord
  self.table_name = "encounter_method"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
