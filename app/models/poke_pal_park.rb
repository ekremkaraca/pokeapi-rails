# == Schema Information
#
# Table name: pal_park
#
#  id         :bigint           not null, primary key
#  base_score :integer          not null
#  rate       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  area_id    :integer          not null
#  species_id :integer          not null
#
# Indexes
#
#  index_pal_park_on_area_id                 (area_id)
#  index_pal_park_on_species_id_and_area_id  (species_id,area_id) UNIQUE
#
class PokePalPark < ApplicationRecord
  self.table_name = "pal_park"

  belongs_to :area,
             class_name: "PokePalParkArea",
             foreign_key: :area_id,
             inverse_of: :pal_parks,
             optional: true
  belongs_to :pokemon_species,
             class_name: "PokePokemonSpecies",
             foreign_key: :species_id,
             inverse_of: :pal_parks,
             optional: true
end
