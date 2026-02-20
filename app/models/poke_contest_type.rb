# == Schema Information
#
# Table name: contest_type
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contest_type_on_name  (name) UNIQUE
#
class PokeContestType < ApplicationRecord
  self.table_name = "contest_type"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
