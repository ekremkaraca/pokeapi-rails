# == Schema Information
#
# Table name: gender
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_gender_on_name  (name) UNIQUE
#
class PokeGender < ApplicationRecord
  self.table_name = "gender"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
