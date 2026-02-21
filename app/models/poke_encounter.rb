# == Schema Information
#
# Table name: encounter
#
#  id                :bigint           not null, primary key
#  max_level         :integer          not null
#  min_level         :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  encounter_slot_id :integer          not null
#  location_area_id  :integer          not null
#  pokemon_id        :integer          not null
#  version_id        :integer          not null
#
# Indexes
#
#  index_encounter_on_encounter_slot_id  (encounter_slot_id)
#  index_encounter_on_location_area_id   (location_area_id)
#  index_encounter_on_pokemon_id         (pokemon_id)
#  index_encounter_on_version_id         (version_id)
#
class PokeEncounter < ApplicationRecord
  self.table_name = "encounter"

  belongs_to :encounter_slot,
             class_name: "PokeEncounterSlot",
             foreign_key: :encounter_slot_id,
             inverse_of: :encounters
  belongs_to :location_area,
             class_name: "PokeLocationArea",
             foreign_key: :location_area_id,
             inverse_of: :encounters
  belongs_to :pokemon,
             class_name: "Pokemon",
             foreign_key: :pokemon_id,
             inverse_of: :encounters
  belongs_to :version,
             class_name: "PokeVersion",
             foreign_key: :version_id,
             inverse_of: :encounters
  has_many :encounter_condition_value_maps,
           class_name: "PokeEncounterConditionValueMap",
           foreign_key: :encounter_id,
           inverse_of: :encounter,
           dependent: :destroy
end
