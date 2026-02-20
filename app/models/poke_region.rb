# == Schema Information
#
# Table name: region
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_region_on_name  (name) UNIQUE
#
class PokeRegion < ApplicationRecord
  self.table_name = "region"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
