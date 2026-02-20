# == Schema Information
#
# Table name: berry_firmness
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_berry_firmness_on_name  (name) UNIQUE
#
class PokeBerryFirmness < ApplicationRecord
  self.table_name = "berry_firmness"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
