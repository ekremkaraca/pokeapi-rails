# == Schema Information
#
# Table name: egg_group
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_egg_group_on_name  (name) UNIQUE
#
class PokeEggGroup < ApplicationRecord
  self.table_name = "egg_group"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
