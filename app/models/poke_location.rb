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

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
