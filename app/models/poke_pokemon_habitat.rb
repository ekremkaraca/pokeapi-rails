# == Schema Information
#
# Table name: pokemon_habitat
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pokemon_habitat_on_name  (name) UNIQUE
#
class PokePokemonHabitat < ApplicationRecord
  self.table_name = "pokemon_habitat"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
