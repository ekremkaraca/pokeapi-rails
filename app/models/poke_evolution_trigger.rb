# == Schema Information
#
# Table name: evolution_trigger
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_evolution_trigger_on_name  (name) UNIQUE
#
class PokeEvolutionTrigger < ApplicationRecord
  self.table_name = "evolution_trigger"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
