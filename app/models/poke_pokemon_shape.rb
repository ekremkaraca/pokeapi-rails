# == Schema Information
#
# Table name: pokemon_shape
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pokemon_shape_on_name  (name) UNIQUE
#
class PokePokemonShape < ApplicationRecord
  self.table_name = "pokemon_shape"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
