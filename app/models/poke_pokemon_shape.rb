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

  has_many :pokemon_species,
           class_name: "PokePokemonSpecies",
           foreign_key: :shape_id,
           inverse_of: :shape,
           dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
