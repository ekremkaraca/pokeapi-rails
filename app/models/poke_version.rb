# == Schema Information
#
# Table name: version
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  version_group_id :integer
#
# Indexes
#
#  index_version_on_name              (name) UNIQUE
#  index_version_on_version_group_id  (version_group_id)
#
class PokeVersion < ApplicationRecord
  self.table_name = "version"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
