# == Schema Information
#
# Table name: generation
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  main_region_id :integer
#
# Indexes
#
#  index_generation_on_main_region_id  (main_region_id)
#  index_generation_on_name            (name) UNIQUE
#
class PokeGeneration < ApplicationRecord
  self.table_name = "generation"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
