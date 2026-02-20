# == Schema Information
#
# Table name: pal_park_area
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pal_park_area_on_name  (name) UNIQUE
#
class PokePalParkArea < ApplicationRecord
  self.table_name = "pal_park_area"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
