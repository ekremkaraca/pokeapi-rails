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

  has_many :encounter_slots,
           class_name: "PokeEncounterSlot",
           foreign_key: :encounter_method_id,
           inverse_of: :encounter_method,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
