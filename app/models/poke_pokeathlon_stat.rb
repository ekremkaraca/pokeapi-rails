# == Schema Information
#
# Table name: pokeathlon_stat
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pokeathlon_stat_on_name  (name) UNIQUE
#
class PokePokeathlonStat < ApplicationRecord
  self.table_name = "pokeathlon_stat"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
