# == Schema Information
#
# Table name: location
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  region_id  :integer
#
# Indexes
#
#  index_location_on_name       (name) UNIQUE
#  index_location_on_region_id  (region_id)
#
class PokeLocation < ApplicationRecord
  self.table_name = "location"

  belongs_to :region,
             class_name: "PokeRegion",
             foreign_key: :region_id,
             inverse_of: :locations,
             optional: true

  has_many :location_areas,
           class_name: "PokeLocationArea",
           foreign_key: :location_id,
           inverse_of: :location,
           dependent: :nullify
  has_many :location_game_indices,
           class_name: "PokeLocationGameIndex",
           foreign_key: :location_id,
           inverse_of: :location,
           dependent: :restrict_with_exception
  has_many :location_names,
           class_name: "PokeLocationName",
           foreign_key: :location_id,
           inverse_of: :location,
           dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
