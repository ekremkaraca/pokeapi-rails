# == Schema Information
#
# Table name: berry_flavor
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contest_type_id :integer
#
# Indexes
#
#  index_berry_flavor_on_contest_type_id  (contest_type_id)
#  index_berry_flavor_on_name             (name) UNIQUE
#
class PokeBerryFlavor < ApplicationRecord
  self.table_name = "berry_flavor"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
