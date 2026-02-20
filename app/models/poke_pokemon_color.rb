# == Schema Information
#
# Table name: pokemon_color
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pokemon_color_on_name  (name) UNIQUE
#
class PokePokemonColor < ApplicationRecord
  self.table_name = "pokemon_color"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
