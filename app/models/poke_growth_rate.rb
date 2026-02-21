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

  has_many :pokemon_species,
           class_name: "PokePokemonSpecies",
           foreign_key: :growth_rate_id,
           inverse_of: :growth_rate,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
