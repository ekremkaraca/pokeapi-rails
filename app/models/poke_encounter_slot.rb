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
end
