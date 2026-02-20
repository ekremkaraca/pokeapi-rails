# == Schema Information
#
# Table name: growth_rate
#
#  id         :bigint           not null, primary key
#  formula    :string
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_growth_rate_on_name  (name) UNIQUE
#
class PokeGrowthRate < ApplicationRecord
  self.table_name = "growth_rate"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
