# == Schema Information
#
# Table name: version_group
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  sort_order    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  generation_id :integer
#
# Indexes
#
#  index_version_group_on_generation_id  (generation_id)
#  index_version_group_on_name           (name) UNIQUE
#  index_version_group_on_sort_order     (sort_order)
#
class PokeVersionGroup < ApplicationRecord
  self.table_name = "version_group"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
