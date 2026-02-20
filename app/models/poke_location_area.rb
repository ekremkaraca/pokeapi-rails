# == Schema Information
#
# Table name: location_area
#
#  id          :bigint           not null, primary key
#  game_index  :integer
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer
#
# Indexes
#
#  index_location_area_on_game_index   (game_index)
#  index_location_area_on_location_id  (location_id)
#  index_location_area_on_name         (name) UNIQUE
#
class PokeLocationArea < ApplicationRecord
  self.table_name = "location_area"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
