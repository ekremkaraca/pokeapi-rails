# == Schema Information
#
# Table name: version_group_region
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  region_id        :integer          not null
#  version_group_id :integer          not null
#
# Indexes
#
#  index_version_group_region_on_region_id                       (region_id)
#  index_version_group_region_on_version_group_id_and_region_id  (version_group_id,region_id) UNIQUE
#
class PokeVersionGroupRegion < ApplicationRecord
  self.table_name = "version_group_region"
end
