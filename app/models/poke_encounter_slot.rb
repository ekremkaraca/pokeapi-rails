# == Schema Information
#
# Table name: encounter_slot
#
#  id                  :bigint           not null, primary key
#  rarity              :integer          not null
#  slot                :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  encounter_method_id :integer          not null
#  version_group_id    :integer          not null
#
# Indexes
#
#  idx_encounter_slot_lookup                    (version_group_id,encounter_method_id,slot,rarity)
#  index_encounter_slot_on_encounter_method_id  (encounter_method_id)
#
class PokeEncounterSlot < ApplicationRecord
  self.table_name = "encounter_slot"

  belongs_to :encounter_method,
             class_name: "PokeEncounterMethod",
             foreign_key: :encounter_method_id,
             inverse_of: :encounter_slots
  belongs_to :version_group,
             class_name: "PokeVersionGroup",
             foreign_key: :version_group_id,
             inverse_of: :encounter_slots
  has_many :encounters,
           class_name: "PokeEncounter",
           foreign_key: :encounter_slot_id,
           inverse_of: :encounter_slot,
           dependent: :restrict_with_exception
end
