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
end
