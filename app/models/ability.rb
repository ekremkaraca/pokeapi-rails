# == Schema Information
#
# Table name: ability
#
#  id             :bigint           not null, primary key
#  is_main_series :boolean          default(TRUE), not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  generation_id  :integer
#
# Indexes
#
#  index_ability_on_generation_id   (generation_id)
#  index_ability_on_is_main_series  (is_main_series)
#  index_ability_on_name            (name) UNIQUE
#
class Ability < ApplicationRecord
  self.table_name = "ability"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
